worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 18
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  if defined?(Resque)
    Resque.redis.quit
  end

end  

after_fork do |server, worker|
  Signal.trap 'TERM' do
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  if defined?(Resque)
    ENV["REDISTOGO_URL"] ||= "redis://localhost:6379" 
    Resque.redis = ENV['REDISTOGO_URL']
  end
      
end