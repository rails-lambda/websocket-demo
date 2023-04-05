require 'aws-sdk-apigatewaymanagementapi'
require 'aws-sdk-dynamodb'

module LambdaCable
  module Client
    CLIENT = Aws::ApiGatewayManagementApi::Client.new region: ENV['AWS_REGION']
  
    def connect(event:, context:)
      return { statusCode: 200 }
    end

    def default(event:, context:)
      puts(event.inspect)
      response = CLIENT.post_to_connection({
        data: event.body,
        connection_id: event.requestContext.connectionId
      })
      return { statusCode: 200 }
    end

    def disconnect(event:, context:)
      puts(event.inspect)
      return { statusCode: 200 }
    end

    extend self
  end
end
