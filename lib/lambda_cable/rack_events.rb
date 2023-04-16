require 'rack/events'
require 'concurrent/array'

module LambdaCable
  class RackEvents
    include Rack::Events::Abstract

    def self.on_finish
      Queue.jobs.push(proc { yield })
    end

    def on_finish(_req, _res)
      Queue.new.call
    end

    private

    class Queue
      class_attribute :jobs, 
        instance_writer: false, 
        default: Concurrent::Array.new

      def call
        jobs.each { |job| job.call }
      ensure
        jobs.clear
      end
    end
  end
end

# Move out of production.rb and application.rb
# require_relative '../app/models/lambda_cable/rack_events'
# config.middleware.use Rack::Events, [ LambdaCable::RackEvents.new ]

# Move into some Railtie:
# initializer "lambda_cable.middleware" do |app|
#   config.app_middleware.use Rack::Events, [ LambdaCable::RackEvents.new ]
# end
