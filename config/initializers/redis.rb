ENV["REDISCLOUD_URL"] ||= 'redis://localhost:6379' 
uri = URI.parse(ENV["REDISCLOUD_URL"])

REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)