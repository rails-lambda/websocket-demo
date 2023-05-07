module LambdaCable
  module Connection
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Base
      autoload :Error
      autoload :InternalChannel
      autoload :MessageBuffer
      autoload :StreamEventLoop
      autoload :Subscriptions
      autoload :SubscriptionsDb
      autoload :WebSocket
    end
  end
end

ActionCable::Connection::Base.prepend LambdaCable::RackEnvConcerns
ActionCable::Connection::Base.prepend LambdaCable::Connection::Base
ActionCable::Connection::Base.prepend LambdaCable::Connection::InternalChannel
ActionCable::Connection::Subscriptions.prepend LambdaCable::Connection::Subscriptions
