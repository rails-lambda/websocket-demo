module LambdaCable
  module Connection
    module InternalChannel
      def subscribe_to_internal_channel
        # TODO: Will this be needed for logout/disconnect?
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Connection::InternalChannel#subscribe_to_internal_channel internal_channel: #{internal_channel.inspect}"
      end

      def unsubscribe_from_internal_channel
        # TODO: Will this be needed for logout/disconnect?
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Connection::InternalChannel#unsubscribe_from_internal_channel internal_channel: #{internal_channel.inspect}"
      end
    end
  end
end
