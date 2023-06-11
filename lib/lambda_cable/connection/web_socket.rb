require 'aws-sdk-apigatewaymanagementapi'

module LambdaCable
  module Connection
    # Override in object for the ActionCable::Connection::Base's @websocket instance variable. Conforms to the same
    # interface as ActionCable::Connection::WebSocket but speaks to API Gateway's managment API and DYnamoDB for state.
    #
    class WebSocket
      include LambdaCable::RackEnvConcerns

      class << self

        def new_from(env, event_target)
          event = env[Lamby::Rack::LAMBDA_EVENT]
          context = env[Lamby::Rack::LAMBDA_CONTEXT]
          new event, context, event_target
        end

      end

      def initialize(event, context, event_target)
        @event, @context, @event_target = event, context, event_target
        @dynamodb = LambdaCable::Server::ConnectionsDb.new(event, context, event_target)
      end

      # Interface: Always true from the perspective of the server. See #alive? for client perspective.
      # 
      def possible?
        true
      end

      # Interface: Check API Gateway for connection status. If gone, allow the connection to receive the close event.
      # 
      def alive?
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::WebSocket#alive? connection_id: #{connection_id}"
        client.get_connection connection_id: connection_id
      rescue *LambdaCable::Connection::Error::GoneExceptions
        LambdaPunch.push { event_target.close }
        false
      end

      # Interface: Send data to the client via API Gateway. If not gone, update the connection's TTL in DynamoDB.
      # If we receive any error from API Gateway, we delete the connection state from DynamoDB. If we receive a
      # disconnect message, we do not update the DynamoDB connections table.
      # 
      def transmit(data)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::WebSocket#transmit connection_id: #{connection_id} data: #{data.inspect}"
        client.post_to_connection data: data, connection_id: connection_id
        LambdaPunch.push { dynamodb.update } unless event_target.public_decode(data)['type'] == 'disconnect'
      rescue *LambdaCable::Connection::Error::GoneExceptions
        close
      end

      # Interface: Close the connection in API Gateway first, then in the background, delete the connection in DynamoDB.
      # 
      def close
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::WebSocket#close connection_id: #{connection_id}"
        LambdaPunch.push { dynamodb.close }
        client.delete_connection connection_id: connection_id
      rescue *LambdaCable::Connection::Error::GoneExceptions
      end

      # Interface: Always wss protocol for API Gateway.
      # 
      def protocol
        'wss'
      end

      # Interface: Rack initiates the WebSocket connection and needs a basic response. See the #open method 
      # for the coordination around how the connection is opened and #rack_response_headers for the headers.
      # 
      def rack_response
        open
        [ 200, rack_response_headers, [] ]
      end

      private

      attr_reader :event, :context, :event_target, :dynamodb

      # This methos has intentional coordination. We know the Connection#on_open will call #send_async
      # with the #handle_open method. This in turn will call your connection's #connect method if defined.
      # Since #send_async is handled by LambdaPunch, we want DynamoDB to open after the #connect in case
      # any identifiers are present for the connection_identifier.
      # 
      def open
        event_target.on_open
        LambdaPunch.push { dynamodb.open }
      end

      # Simple memoized API Gateway client. Pulls the endpoint from the Lambda event.
      # 
      def client
        @client ||= Aws::ApiGatewayManagementApi::Client.new region: ENV['AWS_REGION'], endpoint: apigw_endpoint
      end

      # We select the first protocol that matches ActionCable protocols.
      # 
      def rack_response_headers
        protocols = lambda_event.dig 'headers', 'Sec-WebSocket-Protocol'
        return {} unless protocols
        protocol = protocols.split(',').first { |p| ActionCable::INTERNAL[:protocols].include? p }
        protocol ? { 'Sec-WebSocket-Protocol' => protocol } : {}
      end
    end
  end
end
