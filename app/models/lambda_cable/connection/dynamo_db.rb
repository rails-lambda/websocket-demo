require 'aws-sdk-dynamodb'

module LambdaCable
  module Connection
    class DynamoDb
      include LambdaCable::RackEnvConcerns

      def initialize(env)
        @env = env
      end

      def table_name
        ENV['LAMBDA_CABLE_CONNECTIONS_TABLE']
      end

      def open
        put_connection
      end

      def close
        client.delete_item table_name: table_name, key: { connection_id: connection_id }
      end

      private
      
      attr_reader :env

      def put_connection
        client.put_item table_name: table_name, item: item
      end

      def item
        { connection_id: connection_id,
          updated_at: Time.current.to_s(:db),
          apigw_endpoint: apigw_endpoint,
          ttl: Time.current.advance(seconds: 300).to_i,
        }.tap do |md|
          md[:started_at] = Time.current.to_s(:db) if route_key.connect?
        end
      end

      def client
        @client ||= Aws::DynamoDB::Client.new region: ENV['AWS_REGION']
      end
    end
  end
end
