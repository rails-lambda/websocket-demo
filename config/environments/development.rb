require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Make development like production.
  if ENV['LAMBDA_CABLE_LOCAL_PROXY']
    # LambdaCable.
    ENV['LAMBDA_CABLE_LOG_LEVEL'] = "debug"
    ENV['LAMBDA_CABLE_CONNECTIONS_TABLE'] = "websocket-demo-live-WSTableConnections-NNRTHMFOPZSX"
    ENV['LAMBDA_CABLE_SUBSCRIPTIONS_TABLE'] = "websocket-demo-live-WSTableSubscriptions-11BPGHNABCQ6Z"
    require 'lambda_cable'
    ActionCable::Helpers::ActionCableHelper.prepend LambdaCable::Helpers::ActionCableExtensions
    # MaybeLater
    require 'maybe_later'
    MaybeLater.config.max_threads = 1
    MaybeLater.config.invoke_even_if_server_is_unsupported = true
    MaybeLater.config.inline_by_default = true
    # LambdaPunch.
    ENV['LAMBDA_PUNCH_LOG_LEVEL'] = "debug"
    require 'lambda_punch'
    config.lamby.handled_proc = Proc.new do |_e, c|
      LambdaPunch.handled!(c)
    end
    LambdaPunch.define_method(:handled!) do |_|
      MaybeLater.run(inline: true) { LambdaPunch::Queue.new.call }
    end
    # Simulate production RAILS_LOG_TO_STDOUT.
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
    # Force local development Rails behavior.
    config.web_console.permissions = IPAddr.new("0.0.0.0/0")
    config.host_authorization = { exclude: ->(_) { true } }
    config.hosts += [IPAddr.new("0.0.0.0/0"), IPAddr.new("::/0")]
    # ActionCable
    config.action_cable.allowed_request_origins = ['https://websockets-live.lamby.cloud']
    config.to_prepare { 
      ActionCable::Server::Base.config.cable = {'adapter' => 'lambda_cable'}
    }
  end
end
