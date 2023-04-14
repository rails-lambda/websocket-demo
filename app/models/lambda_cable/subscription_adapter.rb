require "action_cable/subscription_adapter/inline"

module LambdaCable
  class SubscriptionAdapter < ActionCable::SubscriptionAdapter::Inline
    prepend ActionCable::SubscriptionAdapter::ChannelPrefix
    
    # attr_reader :logger, :server
    def initialize(server)
      super
      puts "[DEBUG] SubscriptionAdapter#initialize"
      # @server = server
      # @logger = @server.logger
    end

    def broadcast(channel, payload)
      puts "[DEBUG] SubscriptionAdapter#broadcast to #{channel.inspect} with payload #{payload.inspect}"
    end

    def subscribe(channel, message_callback, success_callback = nil)
      puts "[DEBUG] SubscriptionAdapter#subscribe to #{channel.inspect} with message_callback #{message_callback.inspect} and success_callback #{success_callback.inspect}"
    end

    def unsubscribe(channel, message_callback)
      puts "[DEBUG] SubscriptionAdapter#unsubscribe from #{channel.inspect} with message_callback #{message_callback.inspect}"
    end

    def shutdown
      puts "[DEBUG] SubscriptionAdapter#shutdown"
    end

    # def identifier
    #   @server.config.cable[:id] ||= "ActionCable-PID-#{$$}"
    # end
  end
end

ActionCable::SubscriptionAdapter::LambdaCable = LambdaCable::SubscriptionAdapter
