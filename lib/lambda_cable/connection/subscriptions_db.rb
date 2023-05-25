require 'aws-sdk-dynamodb'

module LambdaCable
  module Connection
    class SubscriptionsDb
      include LambdaCable::RackEnvConcerns

      class << self

        def table_name
          ENV['LAMBDA_CABLE_SUBSCRIPTIONS_TABLE']
        end

      end

      def initialize(connection)
        @connection = connection
      end

      def add(data)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::SubscriptionsDb#open identifier: #{identifier}"
        LambdaCable.dynamodb_client.put_item table_name: table_name, item: item
      end

      def find_all
        resp = LambdaCable.dynamodb_client.query( 
          table_name: table_name, 
          index_name: 'connection_id_index',
          key_condition_expression: "connection_id = :connection_id", 
          expression_attribute_values: { ":connection_id" => connection_id }
        )
        resp.items
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        []
      end

      private

      attr_reader :connection

      def item
        { identifier: identifier,
          connection_id: connection_id }
      end

      def current_time_value
        Time.current.to_fs(:db)
      end

      def connection_id
        connection.connection_id
      end

      delegate :table_name, to: :class
    end
  end
end

# def find(identifier)
#   resp = LambdaCable.dynamodb_client.get_item table_name: table_name, key: { identifier: identifier }
#   resp.item
# rescue Aws::DynamoDB::Errors::ResourceNotFoundException
#   nil
# end
