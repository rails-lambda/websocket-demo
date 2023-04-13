module LambdaCable
  module Connection
    module Base

      def initialize(server, env, coder: ActiveSupport::JSON)
        super
        puts "[DEBUG] LambdaCable::Connection::Base#initialize"
        
      end
      
    end
  end
end

ActionCable::Connection::Base.prepend LambdaCable::Connection::Base
