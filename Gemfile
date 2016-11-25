# ===============
# === bASSIST ===
# === Gemfile ===
# ===============

# --- Standard Gem Source
source 'http://rubygems.org'

# --- Base
gem 'rails', '4.2'

# =================
# === Configure ===
# =================

# --- Database
gem 'sqlite3'
# gem 'pg'
# gem 'mysql2'

# --- Webserver
# gem 'fcgi'
# gem 'thin'

# =================

# --- JavaScript
gem 'jquery-rails'
gem 'jbuilder', '~> 1.2'
gem 'therubyracer', platforms: :ruby
gem 'execjs'
gem 'coffee-rails'
gem 'jquery-datatables-rails', '~> 3.2.0'
gem 'uglifier', '>= 1.3.0'

# --- Crypto
gem "bcrypt-ruby"
gem "attr_encrypted", "~> 1.3.2"

# --- CSS and Twitter Bootstrap
gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass', '~> 3.1.1'
gem 'bootstrap_form', :git => 'git://github.com/bootstrap-ruby/rails-bootstrap-forms.git'
gem "bootstrap-switch-rails"

# --- Deployment
gem 'figaro', '>= 1.0'

# --- Delayed Jobs
gem 'delayed_job_active_record'
gem 'daemons'

# -- Internationalization
gem 'rails-i18n'

# --- Other gems
gem 'slim-rails'
gem 'draper', '~> 1.3'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'rb-readline'
gem 'yaml_db'

# http client
gem 'curb'

# Unicode algorithms
#   gem 'unicode_utils'

# Generate files (pdfs,zip)
gem 'prawn'
gem 'prawn_rails'
gem 'rubyzip', '>= 1.0.0'
gem 'zip-zip'

group :development do
  gem 'awesome_print'       # console highlighting
  gem 'better_errors'       # improve in browser error messages
  gem 'meta_request'        # show log in Chrome dev tools with RailsPanel addon
  gem 'web-console', '~> 2.0' 
  gem 'pry'
  gem 'pry-doc'
  gem 'method_source'
  gem 'binding_of_caller'
  gem 'hirb-unicode'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :production do
  # gem 'rails_12factor'
end
