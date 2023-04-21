module LambdaCable
  module Connection
    # As far as I can tell, there is only one need for an internal channel, 
    # to disconnect users. We are going to NOP all methods here since a disconnect 
    # will be a simple HTTP request to API Gateway using the Connection ID. 
    # May look into using the Connection ID as the Channel#connection_identifier to
    # help with that disconnect.
    #
    module InternalChannel
      # NOP since disconnect happens elsewhere.
      def subscribe_to_internal_channel
      end

      # NOP since disconnect happens elsewhere.
      def unsubscribe_from_internal_channel
      end
    end
  end
end
