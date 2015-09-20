# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]
Rails.application.config.filter_parameters += [:password_confirmation]
Rails.application.config.filter_parameters += [:teacher_key]
Rails.application.config.filter_parameters += [:tutor_key]
