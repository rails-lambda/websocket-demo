module Lamby
  class Command

    class << self

      def handle?(event)
        event.dig 'lamby', 'command'
      end

      def cmd(event:, context:)
        new(event).call
      end

    end

    def initialize(event)
      @event = event
      @body = ''
    end

    def call
      begin
        body = eval(command, TOPLEVEL_BINDING).to_s
        body = body.inspect if body =~ /\A"/ && body =~ /"\z/
        { statusCode: 200, headers: {}, body: body }
      rescue Exception => e
        body = "#<#{e.class}:#{e.message}>".tap do |b|
          if e.backtrace
            b << "\n"
            b << e.backtrace.join("\n")
          end
        end
        { statusCode: 422, headers: {}, body: body }
      end
    end

    def command
      @event.dig 'lamby', 'command'
    end

  end
end

module Lamby
  class Handler

    private

    def call_app
      if Debug.on?(@event)
        Debug.call @event, @context, rack.env
      elsif rack?
        @status, @headers, @body = @app.call rack.env 
        set_cookies
        rack_response
      elsif lambdakiq?
        Lambdakiq.cmd event: @event, context: @context
      elsif lambda_cable?
        LambdaCable.cmd event: @event, context: @context
      elsif console?
        Lamby::Command.cmd event: @event, context: @context
      elsif runner?
        @status, @headers, @body = Runner.call(@event)
        { statusCode: status, headers: headers, body: body }
      elsif event_bridge?
        Lamby.config.event_bridge_handler.call @event, @context
      else
        [404, {}, StringIO.new('')]
      end
    end

    def console?
      Lamby::Command.handle?(@event)
    end

  end
end
