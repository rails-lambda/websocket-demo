require 'aws-sdk-dynamodb'

module LambdaCable
  module Server
    class ConnectionsDb
      include LambdaCable::RackEnvConcerns

      class << self

        def connection(event, context)
          connection_id = event.dig 'requestContext', 'connectionId'
          db_item = item(connection_id)
          return unless db_item
          new event.dup.merge!(db_item['connect_env']), context
        end

        def item(connection_id)
          resp = client.get_item table_name: table_name, key: { connection_id: connection_id }
          resp.item
        rescue Aws::DynamoDB::Errors::ResourceNotFoundException
          nil
        end

        def client
          @client ||= Aws::DynamoDB::Client.new region: ENV['AWS_REGION']
        end

        def table_name
          ENV['LAMBDA_CABLE_CONNECTIONS_TABLE']
        end

      end

      def initialize(event, context)
        @event, @context = event, context
      end

      def open
        client.put_item table_name: table_name, item: item
      end

      def message
        res = connection.dispatch_websocket_message lambda_event['body']
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::ConnectionsDb#message res: #{res.inspect}"
        LambdaPunch.push { update }
      end

      def close
        client.delete_item table_name: table_name, key: { connection_id: connection_id }
      end

      private

      attr_reader :event, :context

      def item
        { connection_id: connection_id,
          updated_at: current_time_value,
          apigw_endpoint: apigw_endpoint,
          connect_env: lambda_event_connect_properties,
          started_at: current_time_value,
          ttl: ttl_value }
      end

      def item_update_values
        { ":updated_at" => current_time_value,
          ":apigw_endpoint" => apigw_endpoint,
          ":ttl" => ttl_value }
      end

      def update
        client.update_item table_name: table_name, key: { connection_id: connection_id }, 
          update_expression: "SET updated_at = :updated_at, apigw_endpoint = :apigw_endpoint, #ttl_attribute = :ttl",
          expression_attribute_values: item_update_values,
          expression_attribute_names: { "#ttl_attribute" => "ttl" }
      end

      # This creates a new ActionCable connection object for each $default request since 
      # Lambda does not long running persisted connectoins. Since $default events 
      # from API Gateway does not include identifing information such as headers, we
      # retrieve the CONNECT_EVENT_PROPERTIES (such as headers) from the connection recorded 
      # in DynamoDB. This allows us to merge it with the $default event so connections have 
      # access again to session information. This simulates the behavior of a persisted 
      # connection object. We also bypass the following WebSocket behavior since it is not
      # needed for $default requests when using the #message method:
      #
      #   - Connection#on_message(data)
      #   - Connection#message_buffer.append(message)
      #   - MessageBuffer#receive(message)
      #   - Connection#receive(websocket_message)
      #   - Connection#send_async(:dispatch_websocket_message, websocket_message)
      #
      def connection
        @connection ||= begin
          connection_class = ActionCable.server.config.connection_class.call
          connection_class.new ActionCable.server, lambda_rack_env
        end
      end

      def ttl_value
        Time.current.advance(seconds: 60).to_i
      end

      def current_time_value
        Time.current.to_fs(:db)
      end

      delegate :client, :table_name, to: :class
    end
  end
end
