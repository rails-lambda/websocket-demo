require 'aws-sdk-apigatewaymanagementapi'

module LambdaCable
  module Connection
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

      def possible?
        true
      end

      def alive?
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::WebSocket#alive? connection_id: #{connection_id}"
        client.get_connection connection_id: connection_id
      rescue *LambdaCable::Connection::Error::GoneExceptions
        LambdaPunch.push { event_target.close }
        false
      end

      def transmit(data)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::WebSocket#transmit connection_id: #{connection_id} data: #{data.inspect}"
        client.post_to_connection data: data, connection_id: connection_id
        LambdaPunch.push { dynamodb.update }
      rescue *LambdaCable::Connection::Error::GoneExceptions
        close
      end

      def close
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::WebSocket#close connection_id: #{connection_id}"
        LambdaPunch.push { dynamodb.close }
        client.delete_connection connection_id: connection_id
      rescue *LambdaCable::Connection::Error::GoneExceptions
      end

      def protocol
        'wss'
      end

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

      def client
        @client ||= Aws::ApiGatewayManagementApi::Client.new region: ENV['AWS_REGION'], endpoint: apigw_endpoint
      end

      def rack_response_headers
        protocols = lambda_event.dig 'headers', 'Sec-WebSocket-Protocol'
        return {} unless protocols
        protocol = protocols.split(',').first { |p| ActionCable::INTERNAL[:protocols].include? p }
        protocol ? { 'Sec-WebSocket-Protocol' => protocol } : {}
      end
    end
  end
end
