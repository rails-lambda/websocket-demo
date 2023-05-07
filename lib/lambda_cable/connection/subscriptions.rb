module LambdaCable
  module Connection
    module Subscriptions

      def initialize(connection)
        super
        @subscriptions_db = SubscriptionsDb.new(connection)
      end

      def add(data)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::Subscriptions#add data: #{data}"
        id_key = data["identifier"]
        id_options = ActiveSupport::JSON.decode(id_key).with_indifferent_access
        return if subscriptions.key?(id_key)
        subscription_klass = id_options[:channel].safe_constantize
        if subscription_klass && ActionCable::Channel::Base > subscription_klass
          subscription = subscription_klass.new(connection, id_key, id_options)
          subscriptions[id_key] = subscription
          subscription.subscribe_to_channel
        else
          logger.error "Subscription class not found: #{id_options[:channel].inspect}"
        end
      end

      # def remove(data)
      #   logger.info "Unsubscribing from channel: #{data['identifier']}"
      #   remove_subscription find(data)
      # end

      # def remove_subscription(subscription)
      #   subscription.unsubscribe_from_channel
      #   subscriptions.delete(subscription.identifier)
      # end

      # def perform_action(data)
      #   find(data).perform_action ActiveSupport::JSON.decode(data["data"])
      # end

      # def identifiers
      #   subscriptions.keys
      # end

      # def unsubscribe_from_all
      #   subscriptions.each { |id, channel| remove_subscription(channel) }
      # end

      private

      attr_reader :subscriptions_db

      def subscriptions
        @subscriptions_from_db ||= subscriptions_db.find_all
        
      end

      # attr_reader :connection, :subscriptions
      # delegate :logger, to: :connection
      # 
      # def find(data)
      #   if subscription = subscriptions[data["identifier"]]
      #     subscription
      #   else
      #     raise "Unable to find subscription with identifier: #{data['identifier']}"
      #   end
      # end
    end
  end
end
