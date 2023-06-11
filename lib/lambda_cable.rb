# s.add_dependency "activesupport"
# s.add_dependency "actioncable", ">= 6.0.0"
# s.add_dependency "aws-sdk-apigatewaymanagementapi"
# s.add_dependency "aws-sdk-dynamodb"

require 'lamby'
require 'base64'
require 'logger'
require 'action_cable'
require 'active_support/current_attributes' 
require 'lambda_cable/version'
# Force freedom patching with Module.prepend.
require 'lambda_cable/rack_env_concerns'
require 'lambda_cable/connection'
require 'lambda_cable/server'

ActionCable::Server::Base.config.worker_pool_size = 1

module LambdaCable
  extend ActiveSupport::Autoload

  autoload :Configuration
  autoload :Current
  autoload :Handler
  autoload :Logger
  autoload :RackEnvConcerns
  autoload :SubscriptionAdapter

  def self.cmd(event:, context:)
    Handler.cmd(event: event, context: context)
  end

  def self.handle?(event, context)
    Handler.handle?(event, context)
  end

  def self.logger
    @logger ||= LambdaCable::Logger.new.logger
  end

  def self.config
    @config ||= LambdaCable::Configuration.new
  end

  def self.dynamodb_client
    @dynamodb_client ||= begin
      require 'aws-sdk-dynamodb'
      Aws::DynamoDB::Client.new region: ENV['AWS_REGION']
    end
  end
end

require 'lambda_cable/engine'
require 'lambda_cable/helpers/lambda_cable_helpers'
