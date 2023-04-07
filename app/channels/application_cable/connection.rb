module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      reject_unauthorized_connection unless verified_user
      self.current_user = verified_user
    end

    private
    
    def verified_user
      cookies.encrypted[:user]
    end
  end
end
