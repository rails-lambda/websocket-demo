module LambdaCable
  module Connection
    class StreamEventLoop
      def post(task = nil, &block)
        puts "[DEBUG] LambdaCable::Connection::StreamEventLoop#post"
        task ||= block
        LambdaPunch.push { task.call }
      end

      def attach(*args)
        puts "[DEBUG] LambdaCable::Connection::StreamEventLoop#attach"
        # TODO: See Connection::Stream#hijack_rack_socket
      end

      def detach(*args)
        puts "[DEBUG] LambdaCable::Connection::StreamEventLoop#detach"
        # TODO: See Connection::Stream#clean_rack_hijack
      end

      def writes_pending(*args)
        puts "[DEBUG] LambdaCable::Connection::StreamEventLoop#writes_pending"
        # TODO: See Connection::Stream#write(data)
      end

      def stop
        true
      end
    end
  end
end
