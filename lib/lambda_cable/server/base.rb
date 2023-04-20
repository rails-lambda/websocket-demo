module LambdaCable
  module Server
    class Base
      def event_loop
        @event_loop || LambdaCable::Server::StreamEventLoop.new
      end
    end
  end
end
