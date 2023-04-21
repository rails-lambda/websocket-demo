module LambdaCable
  module Connection
    class StreamEventLoop
      def post(task = nil, &block)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::StreamEventLoop#post"
        task ||= block
        LambdaPunch.push { task.call }
      end

      def attach(*args)
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Connection::StreamEventLoop#attach"
        # TODO: See Connection::Stream#hijack_rack_socket
      end

      def detach(*args)
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Connection::StreamEventLoop#detach"
        # TODO: See Connection::Stream#clean_rack_hijack
      end

      def writes_pending(*args)
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Connection::StreamEventLoop#writes_pending"
        # TODO: See Connection::Stream#write(data)
      end

      def stop
        true
      end
    end
  end
end
