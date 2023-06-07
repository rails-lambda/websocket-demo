module LambdaCable
  module Connection
    # This class fronts the Subscriptions DynamoDB table yet is typed to act like a Hash so that 
    # can be used for the `ActionCable::Connection::Subscriptions` `@subscriptions`` instance variable.
    # 
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

      def put(identifier)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::SubscriptionsDb#put identifier: #{identifier}"
        LambdaCable.dynamodb_client.put_item table_name: table_name, item: item(identifier)
      end

      def get(identifier)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::SubscriptionsDb#get identifier: #{identifier}"
        resp = LambdaCable.dynamodb_client.get_item table_name: table_name, key: { identifier: identifier }
        resp.item
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::SubscriptionsDb#get ERROR!"
        nil
      end

      def delete(identifier)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::SubscriptionsDb#delete identifier: #{identifier}"
        LambdaCable.dynamodb_client.delete_item table_name: table_name, key: { identifier: identifier }
      end

      def items
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::SubscriptionsDb#items"
        resp = LambdaCable.dynamodb_client.query( 
          table_name: table_name, 
          index_name: 'connection_id_index',
          key_condition_expression: "connection_id = :connection_id", 
          expression_attribute_values: { ":connection_id" => connection_id }
        )
        resp.items
      rescue Aws::DynamoDB::Errors::ResourceNotFoundException
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::SubscriptionsDb#items ERROR!"
        []
      end

      private

      attr_reader :connection

      def item(identifier)
        { identifier: identifier,
          connection_id: connection_id }
      end

      def connection_id
        connection.connection_id
      end

      delegate :table_name, to: :class
    end
  end
end
