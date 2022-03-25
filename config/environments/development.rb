Bassist::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do eager load code on boot.
  # Disable lazy loading to prevent problems with single table inheritance.
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Configure SMTP Settings for action mailer.
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  #
  config.action_mailer.default_url_options = {:host => Figaro.env.host_url}
  config.action_mailer.default_options = {:from => Figaro.env.mailer_default_from}
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address        => Figaro.env.mailer_smtp_host,
    :port           => Figaro.env.mailer_smtp_port,
    :authentication => Figaro.env.mailer_auth,
    :user_name      => Figaro.env.mailer_user,
    :password       => Figaro.env.mailer_pw,
    :enable_starttls_auto => Figaro.env.mailer_startls
  }

end
