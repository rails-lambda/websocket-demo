module LambdaCable
  module Connection
    class MessageBuffer
      def initialize(connection)
        @connection = connection
      end

      # Interface: Hook into LambdaPunch as our buffer.
      # 
      def append(message)
        if message.is_a?(String)
          LambdaPunch.push { connection.receive message }
        else
          @connection.logger.error "Couldn't handle non-string message: #{message.class}"
        end
      end

      # Interface: NOP since LambdaPunch will handle this for us automatically.
      # 
      def process!
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Connection::MessageBuffer#process!"
      end
    end
  end
end
