module LambdaCable
  module Handler
    extend self

    def connect(event:, context:)
      puts(event.to_json)
      puts(context.to_json)
      return { statusCode: 200 }
    end

    def default(event:, context:)
      puts(event.to_json)
      puts(context.to_json)
      # response = CLIENT.post_to_connection({
      #   data: event.body,
      #   connection_id: event.requestContext.connectionId
      # })
      return { statusCode: 200 }
    end

    def disconnect(event:, context:)
      puts(event.to_json)
      puts(context.to_json)
      return { statusCode: 200 }
    end
  end
end
