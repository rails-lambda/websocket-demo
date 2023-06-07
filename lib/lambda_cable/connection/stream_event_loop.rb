module LambdaCable
  module Connection
    class StreamEventLoop
      def post(task = nil, &block)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::StreamEventLoop#post"
        task ||= block
        LambdaPunch.push { task.call }
      end

      def attach(*args)
        LambdaCable.logger.debug "[DEBUG] [⚠️] LambdaCable::Connection::StreamEventLoop#attach called!!!"
      end

      def detach(*args)
        LambdaCable.logger.debug "[DEBUG] [⚠️] LambdaCable::Connection::StreamEventLoop#detach called!!!"
      end

      def writes_pending(*args)
        LambdaCable.logger.debug "[DEBUG] [⚠️] LambdaCable::Connection::StreamEventLoop#writes_pending called!!!"
      end

      def stop
        true
      end
    end
  end
end
