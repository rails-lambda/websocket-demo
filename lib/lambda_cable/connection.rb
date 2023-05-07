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

base = ActionCable::Connection::Base
base.prepend LambdaCable::RackEnvConcerns
base.prepend LambdaCable::Connection::Base
base.prepend LambdaCable::Connection::InternalChannel
base.prepend LambdaCable::Connection::Subscriptions
