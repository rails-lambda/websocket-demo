require 'aws-sdk-dynamodb'

module LambdaCable
  module Server
    class ConnectionsDb
      TTL_VALUE = 10.minutes
      CONNECTED_EVENT_PROPERTIES = ['headers', 'multiValueHeaders']

      include LambdaCable::RackEnvConcerns

      class << self

        def find(connection_id)
          resp = LambdaCable.dynamodb_client.get_item table_name: table_name, key: { connection_id: connection_id }
          resp.item
        rescue Aws::DynamoDB::Errors::ResourceNotFoundException
          nil
        end

        def table_name
          ENV['LAMBDA_CABLE_CONNECTIONS_TABLE']
        end

      end

      def initialize(event, context, connection)
        @event, @context, @connection = event, context, connection
      end

      def open
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::ConnectionsDb#open connection_id: #{connection_id}, connection_identifier: #{connection_identifier}"
        LambdaCable.dynamodb_client.put_item table_name: table_name, item: item
      end

      def close
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::ConnectionsDb#close connection_id: #{connection_id}"
        LambdaCable.dynamodb_client.delete_item table_name: table_name, key: { connection_id: connection_id }
      end

      def update
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::ConnectionsDb#update connection_id: #{connection_id}"
        LambdaCable.dynamodb_client.update_item table_name: table_name, key: { connection_id: connection_id }, 
          update_expression: "SET #UA = :ua, #API = :api, #TTL = :ttl",
          expression_attribute_values: { ":ua" => current_time_value, ":api" => apigw_endpoint, ":ttl" => ttl_value },
          expression_attribute_names: { "#UA" => "updated_at", "#API" => "apigw_endpoint", "#TTL" => "ttl" },
          condition_expression: "attribute_exists(connection_id)"
      end

      private

      attr_reader :event, :context, :connection

      def item
        { connection_id: connection_id,
          connection_identifier: connection_identifier,
          updated_at: current_time_value,
          apigw_endpoint: apigw_endpoint,
          connected_event: connected_event,
          started_at: current_time_value,
          ttl: ttl_value }
      end

      def ttl_value
        Time.current.advance(seconds: TTL_VALUE).to_i
      end

      def current_time_value
        Time.current.to_fs(:db)
      end

      def connected_event
        lambda_event.slice(*CONNECTED_EVENT_PROPERTIES).to_json
      end

      def connection_identifier
        connection.connection_identifier || connection_id
      end

      delegate :table_name, to: :class
      
    end
  end
end
