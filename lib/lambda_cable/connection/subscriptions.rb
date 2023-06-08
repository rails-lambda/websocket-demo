module LambdaCable
  module Connection
    # Mixed into the `ActionCable::Connection::Subscriptions` class for specific behavior overrides.
    # 
    module Subscriptions

      # Override: We override `@subscriptions` to use our own `SubscriptionsCollection` class.
      # 
      def initialize(connection)
        super
        @subscriptions = SubscriptionsCollection.new(connection)
      end

    end
  end
end
