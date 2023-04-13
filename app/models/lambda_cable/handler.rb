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
        connect event: event, context: context
      when '$disconnect'
        disconnect event: event, context: context
      end
    end

    private

    def connect(event:, context:)
      response = action_cable_server event, context
      puts "[DEBUG] response: #{response.inspect}"
      response
      # { statusCode: 200 };
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

    # def action_cable_server(event, context)
    #   event = event_with_action_cable_path(event)
    #   klass = Lamby::Rack.lookup nil, event
    #   env = klass.new(event, context).env
    #   ActionCable.server.call(env)
    # end

    def action_cable_server(event, context)
      event = event_with_action_cable_path(event)
      Lamby.cmd event: event, context: context
    end

    def event_with_action_cable_path(event)
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
