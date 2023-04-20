module LambdaCable
  module Server
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Base
      autoload :Connections
      autoload :ConnectionsDb
    end
  end
end

ActionCable::Server::Base.prepend LambdaCable::Server::Base
ActionCable::Server::Connections.prepend LambdaCable::Server::Connections
