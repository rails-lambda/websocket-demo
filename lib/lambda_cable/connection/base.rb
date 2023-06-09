module LambdaCable
  module Connection
    module Base

      class << self

        # This creates a new ActionCable connection object for each $default request since Lambda does 
        # not have long-running persisted connections & API Gateway $default events do not include identifing
        # info such as request headers. We work around stateful connections by retrieving the needed connected 
        # event properties from DynamoDB and merging them into the $default event. This simulates the 
        # behavior of a persisted connection object which may require session information.
        #
        def restore_from(event, context)
          connection_id = event.dig 'requestContext', 'connectionId'
          connected_event = LambdaCable::Server::ConnectionsDb.find(connection_id)&.[]('connected_event')
          restored_event = event.dup.merge! JSON.parse(connected_event || '{}')
          restored_class = ActionCable.server.config.connection_class.call # Most likely ActionCable::Connection::Base
          restored_class.new(ActionCable.server, Lamby::RackRest.new(restored_event, context).env).tap do |connection|
            connection.instance_variable_set :@restored, connected_event.present?
          end
        end

      end

      # Override: Create our own WebSocket & MessageBuffer objects.
      # 
      def initialize(server, env, coder: ActiveSupport::JSON)
        super
        @websocket = LambdaCable::Connection::WebSocket.new_from(env, self)
        @message_buffer = LambdaCable::Connection::MessageBuffer.new(self)
        @restored = false
      end

      # Override: So we can append a connection_id to the message. Helps with dev/debugging.
      # 
      def send_welcome_message
        transmit type: ActionCable::INTERNAL[:message_types][:welcome], connection_id: connection_id
      end

      # Override: Async for us, is using LambaPunch to process blocks after the response.
      # 
      def send_async(method, *arguments)
        LambdaPunch.push { send method, *arguments }
      end

      # We want the Connections#remove_connection to close the WebSocket connection directly
      # as a byproduct of the Connection#handle_close method which is called via the $disconnect
      # handler event. So no need for a fancy Connection#close which is typical for a server
      # shutdown which also involves a reconnect.
      #
      def websocket_close
        websocket.close
      end

      # The main method for our Handler's default route key. Because we instantiate a 
      # connection on each event, here are the methods we avoid calling within ActionCable
      # starting with their WebSocket driver's on(:message) handler. Cool!
      # 
      #   - ClientSocket#receive_message(data)
      #   - Connection#on_message(data)
      #   - Connection#message_buffer.append(message)
      #   - MessageBuffer#receive(message)
      #   - Connection#receive(websocket_message)
      #   - Connection#send_async(:dispatch_websocket_message, websocket_message)
      # 
      # If we get our JavaScript client-side 1 minute ping message type, we just respond 
      # back and help keep that connection alive from the server-side. Primarily, it helps 
      # us keep DynamoDB connection table item's updated_at timestamp current.
      # 
      # If the connection is not restored properly, we close the WebSocket connection with
      # a server restart reason. Meaning, we can delete DynamoDB items to simulate restarts.
      # 
      def lambda_default(websocket_message)
        if restored?
          case decode(websocket_message)['type']
          when 'ping' then beat
          else dispatch_websocket_message(websocket_message)
          end
          { statusCode: 200 }
        else
          close(reason: ActionCable::INTERNAL[:disconnect_reasons][:server_restart]) if websocket.alive?
          { statusCode: 410 }
        end
      end

      # Main method for our Handler's $disconnect route key.
      # 
      def lambda_disconnect
        if restored?
          send_async :handle_close
          { statusCode: 200 }
        else
          { statusCode: 410 }
        end
      end

      # Allow #decode method to be a public interface.
      # 
      def public_decode(data)
        decode(data)
      end
  
      private

      # Indicates if the connection was restored from DynamoDB successfully or not.
      # 
      def restored?
        @restored
      end

    end
  end
end
