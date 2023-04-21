module LambdaCable
  class Handler
    include LambdaCable::RackEnvConcerns

    def self.cmd(event:, context:)
      new(event, context).handle
    end

    def initialize(event, context)
      puts "[DEBUG] LambdaCable::Handler#initialize"
      puts(event.to_json)
      puts(context.to_json)
      @event, @context = event, context
    end

    def handle
      send(route_key)
    end

    def connect
      Lamby.cmd event: event_to_cable, context: context
    end

    # Shoot past the the following needless methods via a persistent connection.
    #
    #   - Connection#on_message(data)
    #   - Connection#message_buffer.append(message)
    #   - MessageBuffer#receive(message)
    #   - Connection#receive(websocket_message)
    #   - Connection#send_async(:dispatch_websocket_message, websocket_message)
    #
    def default
      # connection_class = ActionCable.server.config.connection_class.call
      # connection = connection_class.new ActionCable.server, lambda_rack_env
      # connection.dispatch_websocket_message(lambda_cable_message)
      { statusCode: 200, headers: {}, body: '' }
    end

    def disconnect
      { statusCode: 200, headers: {}, body: '' }
    end

    private
    attr_reader :event, :context
  end
end
