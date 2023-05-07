require 'action_cable/subscription_adapter/inline'

module LambdaCable
  class SubscriptionAdapter < ActionCable::SubscriptionAdapter::Inline
    prepend ActionCable::SubscriptionAdapter::ChannelPrefix
    
    def initialize(server)
      LambdaCable.logger.debug "[DEBUG] SubscriptionAdapter#initialize"
      super
    end

    def broadcast(channel, payload)
      LambdaCable.logger.debug "[DEBUG] SubscriptionAdapter#broadcast to #{channel.inspect} with payload #{payload.inspect}"
      super
    end

    def subscribe(channel, message_callback, success_callback = nil)
      LambdaCable.logger.debug "[DEBUG] SubscriptionAdapter#subscribe to #{channel.inspect} with message_callback #{message_callback.inspect} and success_callback #{success_callback.inspect}"
      super
    end

    def unsubscribe(channel, message_callback)
      LambdaCable.logger.debug "[DEBUG] SubscriptionAdapter#unsubscribe from #{channel.inspect} with message_callback #{message_callback.inspect}"
      super
    end

    def shutdown
      LambdaCable.logger.debug "[DEBUG] SubscriptionAdapter#shutdown"
      super
    end
  end
end
