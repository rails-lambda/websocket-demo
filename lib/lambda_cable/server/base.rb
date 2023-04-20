module LambdaCable
  module Server
    module Base
      def event_loop
        @event_loop || LambdaCable::Connection::StreamEventLoop.new
      end
    end
  end
end
