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
    end

    def handle
      LambdaCable.logger.debug "[DEBUG] LambdaCable::Handler#handle route_key: #{route_key.inspect} connection_id: #{connection_id.inspect}"
      LambdaCable::Current.connection_id = connection_id
      send(route_key)
    ensure
      LambdaCable.logger.debug "[DEBUG] LambdaPunch.handling..."
      # LambdaPunch.push { LambdaCable::Current.clear_all }
      LambdaPunch.handled!(context)
    end

    def connect
      Lamby.cmd event: lambda_event_with_cable_path, context: context
    end

    def default
      connection.lambda_default(websocket_message)
    end

    def disconnect
      connection.lambda_disconnect
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
