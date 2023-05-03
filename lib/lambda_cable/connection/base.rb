module LambdaCable
  module Connection
    module Base

      class << self

        # This creates a new ActionCable connection object for each $default request since Lambda does 
        # not have long-running persisted connections & API Gateway events do not include identifing info
        # such as request headers. We work around stateful connections by retrieving the needed connected 
        # event properties from DynamoDB and merging them into the $default event. This simulates the 
        # behavior of a persisted connection object which may require session information.
        #
        def restore_from(event, context)
          connection_id = event.dig 'requestContext', 'connectionId'
          connected_event = LambdaCable::Server::ConnectionsDb.find(connection_id)&.[]('connected_event')
          return unless connected_event
          restored_event = event.dup.merge! JSON.parse(connected_event)
          restored_class = ActionCable.server.config.connection_class.call # Most likely ActionCable::Connection::Base
          restored_class.new ActionCable.server, Lamby::RackRest.new(restored_event, context).env
        end

      end

      # Override: Create our own WebSocket & MessageBuffer objects.
      # 
      def initialize(server, env, coder: ActiveSupport::JSON)
        super
        @websocket = LambdaCable::Connection::WebSocket.new_from(env, self)
        @message_buffer = LambdaCable::Connection::MessageBuffer.new(self)
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

      def dispatch_lambda_message
        message = JSON.parse lambda_event['body']
        transmit identifier: message['identifier'], type: ActionCable::INTERNAL[:message_types][:confirmation]
        # dispatch_websocket_message lambda_event['body']
      end

      # Override: Because we instantiate a connection on each event, here are the methods we
      # can avoid invoking starting with the WebSocket driver's on(:message) handler.
      #
      #   - ClientSocket#receive_message(data)
      #   - Connection#on_message(data)
      #   - Connection#message_buffer.append(message)
      #   - MessageBuffer#receive(message)
      #   - Connection#receive(websocket_message)
      #   - Connection#send_async(:dispatch_websocket_message, websocket_message)
      #   - .... 
      #
      # TODO: Makes this tracer reach the end vs. temp hack.
      # def dispatch_websocket_message(websocket_message)
      #   # super lambda_event['body']
      #   # LambdaCable.logger.debug "[DEBUG] LambdaCable::Connection::Base#dispatch_websocket_message websocket_message: #{websocket_message.inspect}"
      #   websocket_message = JSON.parse lambda_event['body']
      #   transmit identifier: websocket_message['identifier'], type: ActionCable::INTERNAL[:message_types][:confirmation]
      #   # LambdaPunch.push { ... }        
      # end

      private

      def handle_close
        logger.info finished_request_message
        puts '1'
        server.remove_connection(self)
        puts '2'
        subscriptions.unsubscribe_from_all
        puts '3'
        unsubscribe_from_internal_channel
        puts '4'
        disconnect if respond_to?(:disconnect)
        puts '5'
      end

    end
  end
end

