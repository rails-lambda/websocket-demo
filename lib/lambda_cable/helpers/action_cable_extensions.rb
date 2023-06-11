module LambdaCable
  module Helpers
    module ActionCableExtensions
      # Override: Prepended to `ActionCable::Helpers::ActionCableHelper` so we can also add a meta 
      # tag for the adapter type. We use this to avoid loading this gems JavaScript file when the 
      # `lambda_cable` adapter is not used.
      # 
      def action_cable_meta_tag
        concat super
        concat tag "meta", name: "action-cable-adapter", content: ActionCable.server.config.cable['adapter']
        concat tag "meta", name: "lambda-cable-ping-interval", content: LambdaCable.config.ping_interval
      end
    end
  end
end
