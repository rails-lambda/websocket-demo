module LambdaCable
  module Server
    module Connections # :nodoc:
      def connections
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::Connections#connections"
      end

      def add_connection(connection)
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Server::Connections#add_connection"
        []
      end

      def remove_connection(connection)
        connection
      end

      def setup_heartbeat_timer
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Server::Connections#setup_heartbeat_timer"
      end

      def open_connections_statistics
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Server::Connections#open_connections_statistics"
      end
    end
  end
end
