module LambdaCable
  module Connection
    # A duck-typed Hash object standing in for `ActionCable::Connection::Subscriptions`'s 
    # `@subscriptions` instance variable. The goal is not to add all Hash methods, but just 
    # the ones that are needed by `ActionCable::Connection::Subscriptions`.
    # 
    # We try to avoid loading the entire collection from the database to avoid unnecessary
    # work for item operations like #key?, #[]=, and #[].
    # 
    class SubscriptionsCollection

      def initialize(connection)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::SubscriptionsCollection#initialize"
        @connection = connection
        @subscriptions_db = SubscriptionsDb.new(connection)
        @collection_loaded = false
        @collection_lazy = {}
      end

      def key?(identifier)
        collection_safe.key?(identifier)
      end

      def [](identifier)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::SubscriptionsCollection#[] identifier: #{identifier}"
        collection_safe[identifier] || collection_lazy_load(identifier)
      end

      def []=(identifier, subscription)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::SubscriptionsCollection#[]= identifier: #{identifier}"
        subscriptions_db.put(identifier)
        collection_safe[identifier] = subscription
      end

      def delete(identifier)
        subscriptions_db.delete(identifier)
        collection_safe.delete(identifier)
      end

      def keys
        collection.keys
      end

      def each
        return collection.each unless block_given?
        collection.each { |i| yield(i) }  
      end  

      private

      attr_reader :connection, :subscriptions_db, :collection_lazy

      def collection
        @collection ||= subscriptions_db.items.each_with_object({}) do |item, hash|
          identifier, subscription = item_to_subscription(item)
          hash[identifier] = subscription
        end.compact.tap do |hash|
          @collection_loaded = true
          hash.merge!(collection_lazy)
          collection_lazy.clear
        end
      end

      def collection_loaded?
        @collection_loaded
      end

      def collection_safe
        collection_loaded? ? collection : collection_lazy
      end

      def collection_lazy_load(identifier)
        item = subscriptions_db.get(identifier)
        _identifier, subscription = item_to_subscription(item)
        return unless subscription
        collection_lazy[identifier] = subscription
        subscription
      end

      def item_to_subscription(item)
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::SubscriptionsCollection#item_to_subscription item: #{item.inspect}"
        return unless item
        id_key = item['identifier']
        id_options = ActiveSupport::JSON.decode(id_key).with_indifferent_access
        subscription_klass = id_options[:channel].safe_constantize
        return if !(subscription_klass && ActionCable::Channel::Base > subscription_klass)
        subscription = subscription_klass.new(connection, id_key, id_options)
        [id_key, subscription]
      end

    end
  end
end
