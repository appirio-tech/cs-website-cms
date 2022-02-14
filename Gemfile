source 'https://rubygems.org'
ruby '1.9.2'

gem 'rails', '5.2.6.2'

gem "compass", "~> 0.12.2"
gem 'sass-rails', '~> 5.0.5'
gem 'jquery-rails', '~> 4.0.1'
gem 'redis'
gem 'unicorn'
gem 'resque', :git => 'https://github.com/hone/resque.git', :branch => 'keepalive', :require => 'resque/server'
gem 'pg', '0.14.1'

gem 'devise', '~> 4.4.2'
gem 'bootstrap-sass', '2.3.2.0'
gem 'simple_form', '4.0.0'
gem 'will_paginate'
gem 'gon', '>= 4.0.2'
gem 'time_diff'
gem 'chronic'
gem 'geocoder'

gem 'refinerycms-dashboard', '>= 2.1.0'
gem 'refinerycms-images', '>= 3.0.0'
gem 'refinerycms-pages', '>= 3.0.0'
gem 'refinerycms-resources', '>= 3.0.0'
gem 'httparty'
gem 'hashie', '1.2.0'
gem 'faye', '0.8.3'
gem 'restforce', '1.1.0'
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
gem 'memcachier'
gem 'dalli'
gem 'encryptor'
gem 'ratchetio', '~> 0.6.0'
gem 'rack-timeout', '0.1.0beta2'

gem 'chosen-rails', '>= 0.9.11.1'
gem "select2-rails" # this is WAY better than chosen as it supports loading remote data
gem 'ckeditor_rails', git: 'git://github.com/tsechingho/ckeditor-rails.git'
gem 'plupload-rails', git: 'git://github.com/thatdutchguy/plupload-rails.git'
gem 'client_side_validations'
gem 'client_side_validations-simple_form', '>= 6.6.0'
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
gem 'pnotify-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 4.2.2'
  gem 'uglifier', '>= 1.0.3'
  gem 'asset_sync'
end

group :development, :test do
  gem 'quiet_assets'
  gem 'annotate', '2.4.0'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'growl'
  gem 'debugger'
  gem 'rspec-rails', '>= 2.11.4'
  gem 'sextant', '>= 0.1.3'
  gem 'quiet_assets'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'sql-logging', '>= 3.0.8'
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

