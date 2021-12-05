require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Bassist
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :de
    # config.i18n.enforce_available_locales = false

    # Auto-loading lib files
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app')

    # The Active Job adapter
    config.active_job.queue_adapter = :sidekiq

    # Rails 5.0 Update
    # 2.3 Halting Callback Chains via throw(:abort)
    # Rails 5.2 Update
    # See: https://stackoverflow.com/questions/49744200/nomethoderror-undefined-method-halt-callback-chains-on-return-false-for-acti
    # ActiveSupport.halt_callback_chains_on_return_false = false

    # Rails 6.0 Update
    # enable 'zeitwerk' autoloading
    config.load_defaults 6.0
    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('app')

  end
end
