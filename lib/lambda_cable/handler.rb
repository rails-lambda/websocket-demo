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

    def default
      return { statusCode: 200 }
    end

    def disconnect
      return { statusCode: 200 }
    end

    private
    attr_reader :event, :context
  end
end