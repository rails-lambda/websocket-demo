module LambdaCable
  module Connection
    class MessageBuffer
      def initialize(connection)
        @connection = connection
      end

      def append(message)
        if message.is_a?(String)
          LambdaPunch.push { connection.receive message }
        else
          @connection.logger.error "Couldn't handle non-string message: #{message.class}"
        end
      end

      # NOP since LambdaPunch will handle this for us automatically.
      def process!
      end
    end
  end
end
