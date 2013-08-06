source 'https://rubygems.org'
ruby '1.9.2'

gem 'rails', '3.2.11'

gem "compass", "~> 0.12.2"
gem 'sass-rails',   '~> 3.2.3'
gem 'jquery-rails', '~> 2.0.0'
gem 'redis'
gem 'unicorn'
gem 'resque', :git => 'http://github.com/hone/resque.git', :branch => 'keepalive', :require => 'resque/server'
gem 'pg', '0.14.1'

gem 'devise', '~> 2.0.0'
gem 'bootstrap-sass', '2.1.1.0'
gem 'simple_form', '2.0.4'
gem 'will_paginate'
gem 'gon'
gem 'time_diff'
gem 'chronic'
gem 'geoip'

gem 'refinerycms-dashboard'
gem 'refinerycms-images'
gem 'refinerycms-pages'
gem 'refinerycms-resources'
gem 'httparty'
gem 'hashie', '1.2.0'
gem 'faye', '0.8.3'
gem 'restforce'
gem 'forcifier', git: 'git://github.com/jeffdonthemic/forcifier.git'
gem 'haml'

# are these 8 needed any longer?
gem 'omniauth-twitter'
gem 'omniauth-github'
gem 'omniauth-facebook'
gem 'omniauth-linkedin'
gem 'omniauth-openid'
gem "omniauth-google-oauth2"
gem 'omniauth-salesforce'

gem "recaptcha", :require => "recaptcha/rails"
gem 'flash_messages_helper'
gem 'remote_syslog_logger'
gem 'newrelic_rpm'
gem 'memcachier'
gem 'dalli'
gem 'encryptor'
gem 'ratchetio', '~> 0.6.0'
gem 'rack-timeout', '0.1.0beta2'

gem 'chosen-rails'
gem "select2-rails" # this is WAY better than chosen as it supports loading remote data
gem 'ckeditor_rails', git: 'git://github.com/tsechingho/ckeditor-rails.git'
gem 'plupload-rails', git: 'git://github.com/thatdutchguy/plupload-rails.git'
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem 'awesome_print'
gem 'carrierwave'
gem 'carrierwave_direct', git: 'git://github.com/jeffdonthemic/carrierwave_direct.git'
gem 'fog'
gem 'nest'
gem 'text'
gem 'feedzirra'
gem 'country-select'
gem 'cloudinary'
gem 'rubyzip'
gem 'librato-metrics'
gem 'docusign_rest'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'asset_sync'
  gem 'turbo-sprockets-rails3'
end

group :development, :test do
  gem 'quiet_assets'
  gem 'annotate', '2.4.0'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'growl'
  gem 'debugger'
  gem 'rspec-rails'
  gem 'sextant'
  gem 'quiet_assets'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'sql-logging'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'vcr'
  gem 'spork'
  gem "guard-spork"  
  gem "rake"
  gem 'webmock'
  gem "mocha"
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request', '0.2.1' # see https://github.com/dejan/rails_panel
end

