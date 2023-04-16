module LambdaCable
  module RackEnvConcerns
    extend ActiveSupport::Concern
    
    private

    def apigw_id
      request_context['apiId']
    end

    def apigw_endpoint
      "https://#{request_context['domainName']}/#{request_context['stage']}"
    end

    def route_key
      @route_key ||= begin
        key = request_context['routeKey'].sub '$', ''
        ActiveSupport::StringInquirer.new(key)
      end
    end

    def connection_id
      request_context['connectionId']
    end

    def request_context
      lambda_event['requestContext']
    end

    def lambda_event
      defined?(event) ? event : env[Lamby::Rack::LAMBDA_EVENT]
    end

    def lambda_context
      defined?(context) ? context : env[Lamby::Rack::LAMBDA_CONTEXT]
    end

    # When the connect happens, it is a proxy from API Gateway which only has a stage path, 
    # not a real path. Because of this we have to append the cable mount path to the Lambda
    # event prior to letting Lamby.cmd handle the request. This way we get the full Rails 
    # and Lamby lifecycle as though API Gateway's WebSocket was talking to Rails directly.
    #
    def event_to_cable
      mount_path = ActionCable.server.config.mount_path || '/cable'
      lambda_event.dup.tap do |e|
        e['path'] ||= mount_path
        e['httpMethod'] ||= 'GET'
        e['requestContext'].merge!({
          "resourcePath": mount_path
        })
      end
    end
  end
end