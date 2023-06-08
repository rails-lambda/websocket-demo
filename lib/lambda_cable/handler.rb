module LambdaCable
  class Handler
    include LambdaCable::RackEnvConcerns

    def self.cmd(event:, context:)
      new(event, context).handle
    end

    def self.handle?(event, context)
      event.dig('requestContext', 'connectionId') &&
        /\$(connect|default|disconnect)/ === event.dig('requestContext', 'routeKey')
    end

    def initialize(event, context)
      @event, @context = event, context
      ActiveSupport::CurrentAttributes.reset_all
      LambdaCable::Current.connection_id = connection_id
    end

    def handle
      LambdaCable.logger.debug "\n[DEBUG] LambdaCable::Handler#handle route_key: #{route_key.inspect} connection_id: #{connection_id.inspect}"
      send(route_key)
    ensure
      LambdaCable.logger.debug "[DEBUG] LambdaPunch.handling..."
      LambdaPunch.handled!(context)
    end

    def connect
      Lamby.cmd event: lambda_event_with_cable_path, context: context
    end

    def default
      connection.dispatch_lambda_message(websocket_message)
      { statusCode: 200 }
    end

    def disconnect
      connection.send_async :handle_close
      { statusCode: 200 }
    end

    private

    attr_reader :event, :context

    def connection
      @connection ||= LambdaCable::Connection::Base.restore_from event, context
    end

    def websocket_message
      lambda_event['body']
    end
  end
end
