module LambdaCable
  module Connection
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Base
      autoload :WebSocket
      autoload :DynamoDb
    end
  end
end
