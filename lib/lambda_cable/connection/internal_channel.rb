module LambdaCable
  module Connection
    module InternalChannel

      # NOP: There is no need to store an internal channel with this "server". The state for 
      # connections with identifiers is stored in DynamoDB using the `connection_identifier` 
      # property. See where we use `ConnectionsDb.find_identifier` for more details.
      # 
      def subscribe_to_internal_channel
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Connection::InternalChannel#subscribe_to_internal_channel internal_channel: #{internal_channel.inspect}"
      end

      # NOP: See `subscribe_to_internal_channel` for details. This method is called primarily if 
      # the $disconnect event was received from API Gateway. For example, a browser refresh to get 
      # a new connection. When this happens we typically have no `connection_identifier` any more 
      # because of all the other cleanup. Which is fine, there is nothing to do here anyway. See 
      # also the `SubscriptionAdapter#broadcast` method for remote disconnects.
      #
      def unsubscribe_from_internal_channel
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Connection::InternalChannel#unsubscribe_from_internal_channel internal_channel: #{internal_channel.inspect}"
      end
    end
  end
end
