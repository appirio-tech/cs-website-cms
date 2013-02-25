Resque::Server.use(Rack::Auth::Basic) do |user, password|  
  [user, password] == [ENV['WEB_ADMIN_USERNAME'], ENV['WEB_ADMIN_PASSWORD']]  
end