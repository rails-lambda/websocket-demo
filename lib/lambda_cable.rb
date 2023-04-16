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
require_relative 'lambda_cable/version'

ActionCable::Server::Base.config.worker_pool_size = 1

module LambdaCable
  extend ActiveSupport::Autoload

  autoload :Handler
  autoload :RackEnvConcerns
  autoload :Connection
  autoload :RackEvents

  def self.cmd(event:, context:)
    Handler.cmd(event: event, context: context)
  end
end
