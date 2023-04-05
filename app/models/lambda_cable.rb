# s.add_dependency "actioncable", ">= 6.0.0"
# s.add_dependency "rails", ">= 6.0.0"
# s.add_dependency "activesupport"
# s.add_dependency "actionpack"
# s.add_dependency "aws-sdk-apigatewaymanagementapi"
# s.add_dependency "aws-sdk-dynamodb"

require 'action_cable'
require 'lambda_cable/version'
require 'lambda_cable/client'

# require 'lambda_cable/configuration'
# require 'lambda_cable/engine'
# require 'lambda_cable/channel'
# require 'lambda_cable/connection'
# require 'lambda_cable/subscription'
# require 'lambda_cable/subscription_manager'
# require 'lambda_cable/subscription_adapter'


module LambdaCable
  extend ActiveSupport::Autoload

  autoload :Client
end
