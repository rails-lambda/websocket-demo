module LambdaCable
  module Handler
    extend self

    def connect(event:, context:)
      puts "[DEBUG] LambdaCable::Handler#connect"
      puts(event.to_json)
      puts(context.to_json)
      Lamby.cmd event: event, context: context
      return { statusCode: 200 }
    end

    def default(event:, context:)
      puts "[DEBUG] LambdaCable::Handler#default"
      puts(event.to_json)
      puts(context.to_json)
      Lamby.cmd event: event, context: context
      # response = CLIENT.post_to_connection({
      #   data: event.body,
      #   connection_id: event.requestContext.connectionId
      # })
      return { statusCode: 200 }
    end

    def disconnect(event:, context:)
      puts "[DEBUG] LambdaCable::Handler#disconnect"
      puts(event.to_json)
      puts(context.to_json)
      Lamby.cmd event: event, context: context
      return { statusCode: 200 }
    end
  end
end
