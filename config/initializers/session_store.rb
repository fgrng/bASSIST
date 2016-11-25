# Be sure to restart your server when you modify this file.
Bassist::Application.config.session_store :cookie_store, key: '_bassist_session'

# 4.5 Cookies serializer
# ======================
# http://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1
# 
# If you want to use the new JSON-based format in your application, you can
# add an initializer file with the following content.
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
