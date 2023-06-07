module LambdaCable
  module Connection
    # There is no need to coordinate a WebSocket event loop with Rack. All we need to do is push 
    # tasks to LambdaPunch. Other methods have been marked as NOOPs with warning logs just in case 
    # I missed something. From the looks of it, only `Connection::Stream` and methods like 
    # #hijack_rack_socket and #clean_rack_hijack only used this.
    # 
    class StreamEventLoop
      def post(task = nil, &block)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::StreamEventLoop#post"
        task ||= block
        LambdaPunch.push { task.call }
      end

      def attach(*args)
        LambdaCable.logger.debug "[DEBUG] [NOOP] [⚠️] LambdaCable::Connection::StreamEventLoop#attach called!!!"
      end

      def detach(*args)
        LambdaCable.logger.debug "[DEBUG] [NOOP] [⚠️] LambdaCable::Connection::StreamEventLoop#detach called!!!"
      end

      def writes_pending(*args)
        LambdaCable.logger.debug "[DEBUG] [NOOP [⚠️] LambdaCable::Connection::StreamEventLoop#writes_pending called!!!"
      end

      def stop
        true
      end
    end
  end
end
