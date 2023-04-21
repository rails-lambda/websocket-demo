module LambdaCable
  class Handler
    include LambdaCable::RackEnvConcerns

    def self.cmd(event:, context:)
      new(event, context).handle
    end

    def initialize(event, context)
      @event, @context = event, context
    end

    def handle
      LambdaCable.logger.debug "[DEBUG] LambdaCable::Handler#handle route_key: #{route_key.inspect} connection_id: #{connection_id.inspect}"
      send(route_key)
    ensure
      LambdaCable.logger.debug "[DEBUG] LambdaPunch.handled!"
      LambdaPunch.handled!(context)
    end

    def connect
      Lamby.cmd event: lambda_event_with_cable_path, context: context
    end

    def default
      connection = LambdaCable::Server::ConnectionsDb.connection(event, context)
      connection.message
    end

    def disconnect
      { statusCode: 200, headers: {}, body: '' }
    end

    private

    attr_reader :event, :context
  end
end
