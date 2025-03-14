# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Embloy
  # Application class for the Embloy Rails application.
  #
  # This class is responsible for configuring the Rails application.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.action_text.attachments = true
    config.action_mailer.default_url_options = { host: 'embloy.com' }
    config.action_controller.forgery_protection_origin_check = true
    config.middleware.use Rack::Attack
    # config.middleware.use Rack::Protection

    config.active_record.encryption.key_derivation_salt = ENV.fetch('KEY_DERIVATION_SALT_VALUE', nil)
    config.active_record.encryption.primary_key = ENV.fetch('PRIMARY_KEY_VALUE', nil)

    # RailsAdmin related
    config.api_only = true
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Flash
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Session::CookieStore, { key: '_embloy_session' }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
