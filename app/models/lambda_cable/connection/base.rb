module LambdaCable
  module Connection
    module Base
      def initialize(server, env, coder: ActiveSupport::JSON)
        super
        @websocket = LambdaCable::Connection::WebSocket.new(env, self)
      end

      def send_async(method, *arguments)
        LambdaCable::RackEvents.on_finish { send method, *arguments }
      end

      # TEMP: Just getting connect to work.
      def subscribe_to_internal_channel
      end
    end
  end
end

ActionCable::Connection::Base.prepend LambdaCable::Connection::Base
