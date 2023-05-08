module LambdaCable
  module Server
    # For the most part the #connections here are for the "server" to shutdown all or individual 
    # connections via remote internal channels. We will handle that via other means. Mostly via 
    # the ConnectionsDb class on an individual connection basis.
    # 
    module Connections
      # Override: Ignore any per-server state.
      # 
      def connections
        LambdaCable.logger.debug "[DEBUG] LambdaCable::Server::Connections#connections"
        []
      end

      # Override: Ignore any per-server state.
      # 
      def add_connection(connection)
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Server::Connections#add_connection"
        []
      end

      def remove_connection(connection)
        # TODO: Will we need a traditional #close with reason here for remote disconect?
        connection.websocket_close
      end

      # NOP: We use client side heartbeats at 1m intervals with a server response.
      # 
      def setup_heartbeat_timer
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Server::Connections#setup_heartbeat_timer"
      end

      # NOP: These are in DynamoDB and are global vs per server. Also they are eventually 
      # consistent; meaning there will be some connections that are stale. Everything in 
      # Connection#statistics and more should be there.
      # 
      def open_connections_statistics
        LambdaCable.logger.debug "[DEBUG] [NOP] LambdaCable::Server::Connections#open_connections_statistics"
      end
    end
  end
end
