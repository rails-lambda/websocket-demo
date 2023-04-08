require 'aws-sdk-dynamodb'
require 'aws-sdk-apigatewaymanagementapi'

module LambdaCable
  module Client
    CLIENT = Aws::ApiGatewayManagementApi::Client.new region: ENV['AWS_REGION']
  
    def connect(event:, context:)
      puts(event.to_json)
      puts(context.to_json)
      return { statusCode: 200 }
    end

    def default(event:, context:)
      puts(event.to_json)
      puts(context.to_json)
      response = CLIENT.post_to_connection({
        data: event.body,
        connection_id: event.requestContext.connectionId
      })
      return { statusCode: 200 }
    end

    def disconnect(event:, context:)
      puts(event.to_json)
      puts(context.to_json)
      return { statusCode: 200 }
    end

    extend self
  end
end
