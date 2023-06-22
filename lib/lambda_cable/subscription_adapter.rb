# TODO: Change this to base.
require 'action_cable/subscription_adapter/inline'

module LambdaCable
  class SubscriptionAdapter < ActionCable::SubscriptionAdapter::Inline

    # def initialize(*)
    #   super
    #   @subscriber_map = nil
    # end

    def broadcast(channel, payload)
      # TODO: Should this be in LambdaPunch?
      puts "LambdaCable::Current.connection_id: #{LambdaCable::Current.connection_id.inspect}"
      LambdaCable.logger.debug "[DEBUG] SubscriptionAdapter#broadcast to #{channel.inspect} with payload #{payload.inspect}"
      super
    end

    def subscribe(channel, message_callback, success_callback = nil)
      LambdaCable.logger.debug "[DEBUG] SubscriptionAdapter#subscribe to #{channel.inspect} with message_callback #{message_callback.inspect} and success_callback #{success_callback.inspect}"
      # TODO: We need to implement this method and remove super.
      super
    end

    def unsubscribe(channel, message_callback)
      LambdaCable.logger.debug "[DEBUG] SubscriptionAdapter#unsubscribe from #{channel.inspect} with message_callback #{message_callback.inspect}"
      # TODO: We need to implement this method and remove super.
      super
    end

    # NOP: There is no "server" state hence there is no work to do here.
    # 
    def shutdown
      LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::SubscriptionAdapter#shutdown"
    end

    private

    def internal_channel?(channel)
      
    end

    def connections(channel)

    end
  end
end
