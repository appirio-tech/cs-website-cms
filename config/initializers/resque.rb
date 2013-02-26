rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

ENV["REDISTOGO_URL"] ||= "redis://localhost:6379"

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }

# ensure connections are disconnected and connected before forking pg
Resque.before_fork do
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

Resque.after_fork do
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end