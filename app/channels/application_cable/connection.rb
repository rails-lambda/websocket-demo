module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    # def connect
    #   puts "[DEBUG] ApplicationCable::Connection#connect"
    #   puts session_user
    #   reject_unauthorized_connection unless session_user
    #   self.current_user = session_user
    # end

    private

    def session_user
      User.find(session_user_name) if session_user_name.present?
    end

    def session_user_name
      cookies.encrypted['_session']['user_name']
    end
  end
end
