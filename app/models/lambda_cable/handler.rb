module LambdaCable
  module Handler
    extend self

    def connect(event:, context:)
      puts "[DEBUG] LambdaCable::Handler#connect"
      puts(event.to_json)
      puts(context.to_json)
      # Lamby.cmd event: event, context: context
      { statusCode: 200, body: '{"connect":"true"}' };
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
      return { statusCode: 200, body: '{"default":"true"}' }
    end

    def disconnect(event:, context:)
      puts "[DEBUG] LambdaCable::Handler#disconnect"
      puts(event.to_json)
      puts(context.to_json)
      Lamby.cmd event: event, context: context
      return { statusCode: 200, body: '{"disconnect":"true"}' }
    end
  end
end
