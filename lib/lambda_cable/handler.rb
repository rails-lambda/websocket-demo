module LambdaCable
  class Handler
    include LambdaCable::RackEnvConcerns

    def self.cmd(event:, context:)
      new(event, context).handle
    end

    def initialize(event, context)
      @event, @context = event, context
      LambdaCable.logger.debug "[DEBUG] LambdaCable::Handler#initialize event: #{event.inspect} context: #{context.inspect}"
    end

    def handle
      LambdaCable.logger.debug "[DEBUG] LambdaCable::Handler#handle route_key: #{route_key.inspect} connection_id: #{connection_id.inspect}"
      send(route_key)
    ensure
      LambdaCable.logger.debug "[DEBUG] LambdaPunch.handling..."
      LambdaPunch.handled!(context)
    end

    def connect
      Lamby.cmd event: lambda_event_with_cable_path, context: context
    end

    def default
      connection.dispatch_lambda_message
      { statusCode: 200 }
    end

    def disconnect
      # connection...
      { statusCode: 200 }
    end

    private

    attr_reader :event, :context

    def connection
      @connection ||= LambdaCable::Connection::Base.restore_from event, context
    end
  end
end
