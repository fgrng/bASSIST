# Rails 5.0 Update
# 2.19.1 Active Record belongs_to Required by Default Option
Rails.application.config.active_record.belongs_to_required_by_default = false

# Rails 5.0 Update
# 2.19.2 Per-form CSRF Tokens
Rails.application.config.action_controller.per_form_csrf_tokens = true

# Rails 5.0 Update
# 2.19.3 Forgery Protection with Origin Check
Rails.application.config.action_controller.forgery_protection_origin_check = true

# Rails 5.0 Update
# 2.19.7 Configure SSL Options to Enable HSTS with Subdomains
Rails.application.config.ssl_options = { hsts: { subdomains: true } }
