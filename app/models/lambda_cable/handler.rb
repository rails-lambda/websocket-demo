module LambdaCable
  module Handler
    extend self

    def cmd(event:, context:)
      puts "[DEBUG] LambdaCable::Handler#cmd"
      puts(event.to_json)
      puts(context.to_json)
      case event['requestContext']['routeKey']
      when '$default'
        default event: event, context: context
      when '$connect'
        action_cable_server(event)
        connect event: event, context: context
      when '$disconnect'
        disconnect event: event, context: context
      end
    end

    private

    def connect(event:, context:)
      { statusCode: 200 };
    end

    def default(event:, context:)
      # response = CLIENT.post_to_connection({
      #   data: event.body,
      #   connection_id: event.requestContext.connectionId
      # })
      return { statusCode: 200, body: '{"default":"true"}' }
    end

    def disconnect(event:, context:)
      return { statusCode: 200, body: '{"disconnect":"true"}' }
    end

    def action_cable_server(event)
      event = event_with_action_cable(event)
      Lamby.cmd event: event, context: context, rack: :rest
    end

    def event_with_action_cable!(event)
      event.dup.tap do |event|
        event['path'] ||= '/cable'
        event['httpMethod'] ||= 'GET'
        event['requestContext'].merge!({
          "resourcePath": "/cable"
        })
      end
    end
  end
end
