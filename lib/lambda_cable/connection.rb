module LambdaCable
  module Connection
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Base
      autoload :MessageBuffer
      autoload :StreamEventLoop
      autoload :WebSocket
    end
  end
end

ActionCable::Connection::Base.prepend LambdaCable::Connection::Base
