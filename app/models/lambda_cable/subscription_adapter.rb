module LambdaCable
  class SubscriptionAdapter < ActionCable::SubscriptionAdapter::Base
    prepend ActionCable::SubscriptionAdapter::ChannelPrefix
    
    # attr_reader :logger, :server
    # def initialize(server)
    #   @server = server
    #   @logger = @server.logger
    # end

    def broadcast(channel, payload)
      puts "[DEBUG] broadcasting to #{channel.inspect} with payload #{payload.inspect}"
      raise NotImplementedError
    end

    def subscribe(channel, message_callback, success_callback = nil)
      puts "[DEBUG] subscribing to #{channel} with message_callback #{message_callback.inspect} and success_callback #{success_callback.inspect}"
      raise NotImplementedError
    end

    def unsubscribe(channel, message_callback)
      puts "[DEBUG] unsubscribing from #{channel} with message_callback #{message_callback.inspect}"
      raise NotImplementedError
    end

    def shutdown
      puts "[DEBUG] shutting down"
      raise NotImplementedError
    end

    # def identifier
    #   @server.config.cable[:id] ||= "ActionCable-PID-#{$$}"
    # end
  end
end

ActionCable::SubscriptionAdapter::LambdaCable = LambdaCable::SubscriptionAdapter
