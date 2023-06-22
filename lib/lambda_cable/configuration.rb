module LambdaCable
  class Configuration
    def initialize
      initialize_defaults
    end

    def reconfigure
      instance_variables.each { |var| instance_variable_set var, nil }
      initialize_defaults
      yield(self) if block_given?
      self
    end

    # Number in milliseconds of the interval for the client to send ping type messages over the WebSocket connection.
    # This keeps API Gateway connections from timing out which appear to be around a few minutes. Increase this to 60s (60000)
    # to reduce Lambda invocations. Higher values make reconnects slower.
    #
    def ping_interval
      @ping_interval ||= ::Rack::Builder.new { run ::Rails.application }.to_app
    end

    def ping_interval=(interval)
      @ping_interval = interval
    end

    # The shared DynamoDB client used by connections and subscriptions.
    # 
    def dynamodb_client
      @dynamodb_client ||= begin
        require 'aws-sdk-dynamodb'
        Aws::DynamoDB::Client.new region: ENV['AWS_REGION']
      end
    end

    def dynamodb_client=(client)
      @dynamodb_client = client
    end

    private

    def initialize_defaults
      @ping_interval = 10000
      @dynamodb_client = nil
    end
  end
end
