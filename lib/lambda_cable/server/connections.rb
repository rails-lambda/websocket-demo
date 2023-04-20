module LambdaCable
  module Server
    module Connections # :nodoc:
      def connections
        puts "[DEBUG] LambdaCable::Server::Connections#connections"
      end

      def add_connection(connection)
        puts "[DEBUG] LambdaCable::Server::Connections#add_connection: #{connection.inspect}"
        []
      end

      def remove_connection(connection)
        connection
      end

      def setup_heartbeat_timer
        puts "[DEBUG] LambdaCable::Server::Connections#setup_heartbeat_timer"
      end

      def open_connections_statistics
        puts "[DEBUG] LambdaCable::Server::Connections#open_connections_statistics"
      end
    end
  end
end
