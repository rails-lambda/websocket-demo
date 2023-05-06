require 'aws-sdk-apigatewaymanagementapi'

module LambdaCable
  module Connection
    module Error
      GoneExceptions = [
        Aws::ApiGatewayManagementApi::Errors::GoneException,
        Aws::ApiGatewayManagementApi::Errors::Http410Error
      ].freeze
    end
  end
end
