# s.add_dependency "actioncable", ">= 6.0.0"
# s.add_dependency "rails", ">= 6.0.0"
# s.add_dependency "activesupport"
# s.add_dependency "actionpack"
# s.add_dependency "concurrent-ruby"
# s.add_dependency "aws-sdk-apigatewaymanagementapi"
# s.add_dependency "aws-sdk-dynamodb"

require 'lamby'
require 'base64'
require 'action_cable'
require 'lambda_cable/version'
require 'lambda_cable/connection'

ActionCable::Server::Base.config.worker_pool_size = 1

module LambdaCable
  extend ActiveSupport::Autoload

  autoload :Handler
  autoload :RackEnvConcerns
  autoload :RackEvents
  autoload :SubscriptionAdapter

  def self.cmd(event:, context:)
    Handler.cmd(event: event, context: context)
  end
end
