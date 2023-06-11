module LambdaCable
  class Engine < Rails::Engine
    config.lambda_cable = LambdaCable.config

    initializer 'lambda_cable.helpers', after: 'action_cable.helpers' do
      ActionCable::Helpers::ActionCableHelper.prepend LambdaCable::Helpers::ActionCableExtensions
    end
  end
end
