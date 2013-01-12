source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'pg', '0.14.1'

gem 'compass', git: 'git://github.com/chriseppstein/compass.git'
gem 'sass-rails',   '~> 3.2.3'
gem 'jquery-rails', '~> 2.0.0'

gem 'devise', '~> 2.0.0'
gem 'bootstrap-sass', '2.1.1.0'
gem 'simple_form', '2.0.4'

#gem 'refinerycms', '2.0.8'
gem 'refinerycms-dashboard'
gem 'refinerycms-images'
gem 'refinerycms-pages'
gem 'refinerycms-resources'

gem 'refinerycms-bootstrap', git: 'git://github.com/ghoppe/refinerycms-bootstrap.git'
gem 'rest-client', '1.6.7', require: 'rest_client'
gem 'hashie', '1.2.0'

gem 'faye', '0.8.3'
gem 'restforce'

# gems from old site's gemfile
gem 'haml'
gem 'will_paginate'
gem 'httparty'

gem 'ruby-openid', :git => "git://github.com/mbleigh/ruby-openid.git"
gem 'openid_active_record_store'
gem 'omniauth-twitter'
gem 'omniauth-github'
gem 'omniauth-facebook'
gem 'omniauth-linkedin'
gem 'omniauth-openid'
gem 'omniauth-salesforce'
gem 'savon'

gem 'redis'
gem 'thin'
gem 'resque', :git => 'http://github.com/hone/resque.git', :branch => 'keepalive', :require => 'resque/server'
gem "recaptcha", :require => "recaptcha/rails"
gem 'flash_messages_helper'
gem 'remote_syslog_logger'
gem 'dalli'
gem 'encryptor'
gem 'airbrake'

gem 'chosen-rails'
gem "select2-rails" # this is WAY better than chosen as it supports loading remote data
gem 'ckeditor_rails', git: 'git://github.com/tsechingho/ckeditor-rails.git'
gem 'plupload-rails', git: 'git://github.com/thatdutchguy/plupload-rails.git'
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem 'awesome_print'
gem 'fog'
gem 'nest'
gem 'text'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'annotate', '2.4.0'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'spork'
  gem "guard-spork"
  gem 'growl'
  gem 'ruby-debug19'
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'sextant'
  gem 'quiet_assets'  
  gem 'vcr'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'sql-logging'
  gem 'quiet_assets'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem "minitest"
  gem "rake"
  gem 'webmock'
  gem "mocha"
end
