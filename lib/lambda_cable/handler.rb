module LambdaCable
  class Handler
    include LambdaCable::RackEnvConcerns

    def self.cmd(event:, context:)
      new(event, context).handle
    end

    def initialize(event, context)
      LambdaCable.logger.debug "[DEBUG] LambdaCable::Handler#initialize"
      @event, @context = event, context
    end

    def handle
      send(route_key)
    ensure
      LambdaPunch.handled!(context)
      LambdaCable.logger.debug "[DEBUG] LambdaPunch.handled!"
    end

    def connect
      Lamby.cmd event: event_to_cable, context: context
    end

    def default
      # connection.dispatch_websocket_message(lambda_cable_message)
      { statusCode: 200, headers: {}, body: '' }
    end

    def disconnect
      { statusCode: 200, headers: {}, body: '' }
    end

    private

    attr_reader :event, :context

    # Shoot past the the following needless methods via a persistent connection.
    #
    #   - Connection#on_message(data)
    #   - Connection#message_buffer.append(message)
    #   - MessageBuffer#receive(message)
    #   - Connection#receive(websocket_message)
    #   - Connection#send_async(:dispatch_websocket_message, websocket_message)
    #
    def connection
      @connection ||= begin
        connection_class = ActionCable.server.config.connection_class.call
        connection_class.new ActionCable.server, lambda_rack_env
      end
    end
  end
end
