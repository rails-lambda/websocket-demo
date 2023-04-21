module LambdaCable
  module Connection
    module Base
      def initialize(server, env, coder: ActiveSupport::JSON)
        super
        @websocket = LambdaCable::Connection::WebSocket.new_from(env, self)
        @message_buffer = LambdaCable::Connection::MessageBuffer.new(self)
      end

      def send_async(method, *arguments)
        LambdaPunch.push { send method, *arguments }
      end
    end
  end
end
