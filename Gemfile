# ===============
# === bASSIST ===
# === Gemfile ===
# ===============

# --- Standard Gem Source
source 'https://rubygems.org'

# --- Base
gem 'rails', '7.0.2.3'
gem "sprockets-rails"

# =================
# === Configure ===
# =================

# --- Database
gem 'sqlite3'
# gem 'pg'
# gem 'mysql2'

# --- Webserver
# gem 'fcgi'
gem 'thin'

# =================

# --- JavaScript
gem 'jquery-rails'
# gem 'jbuilder'
# gem 'therubyracer', platforms: :ruby
# gem 'execjs'
gem 'coffee-rails'
gem 'jquery-datatables-rails'
gem 'uglifier'

# --- Crypto
gem "bcrypt", '~> 3.1.7'

# --- CSS and Twitter Bootstrap
gem 'sass-rails'
gem 'bootstrap-sass'
gem 'bootstrap_form', github: 'bootstrap-ruby/rails-bootstrap-forms'
gem "bootstrap-switch-rails"

# --- Deployment
gem 'figaro'

# --- Active Jobs
gem 'sidekiq'
# gem 'delayed_job_active_record'
# gem 'daemons'

# -- Internationalization
gem 'rails-i18n'

# --- Other gems
gem 'slim-rails'
gem 'draper', github: 'audionerd/draper', branch: 'rails5'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
### gem 'rb-readline'
### gem 'yaml_db'
### gem 'activemodel-serializers-xml'

# GitHub Advisory Database / CVE-2021-22942
# See: https://github.com/advisories/GHSA-2rqw-v265-jf8c
gem "actionpack", ">= 6.1.4"
# GitHub Advisory Database / CVE-2022-21831
# See: https://github.com/advisories/GHSA-w749-p3v6-hccq
gem "activestorage", ">= 6.1.4.7"
# GitHub Advisory Database
# See: https://github.com/advisories/GHSA-fq42-c5rg-92c2 
gem "nokogiri", ">= 1.13.2"

# http client
gem 'curb'

# Unicode algorithms
#   gem 'unicode_utils'

# Generate files (pdfs,zip)
# gem 'prawn'
# gem 'prawn_rails'
# gem 'rubyzip'
# gem 'zip-zip'

group :development do
  # gem 'awesome_print'       # console highlighting
  # gem 'better_errors'       # improve in browser error messages
  # gem 'meta_request'        # show log in Chrome dev tools with RailsPanel addon
  gem 'web-console'
  # gem 'pry'
  # gem 'pry-doc'
  # gem 'method_source'
  # gem 'binding_of_caller'
  # gem 'hirb-unicode'
end
