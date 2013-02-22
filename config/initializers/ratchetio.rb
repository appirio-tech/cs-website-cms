require 'ratchetio/rails'
Ratchetio.configure do |config|
  config.access_token = '047a632a551544048422d1c170094629'

  # By default, Ratchetio will try to call the `current_user` controller method
  # to fetch the logged-in user object, and then call that object's `id`,
  # `username`, and `email` methods to fetch those properties. To customize:
  # config.person_method = "my_current_user"
  # config.person_id_method = "my_id"
  # config.person_username_method = "my_username"
  # config.person_email_method = "my_email"

  # Add exception class names to the exception_level_filters hash to
  # change the level that exception is reported at. Note that if an exception
  # has already been reported and logged the level will need to be changed
  # via the ratchet.io interface.
  # Valid levels: 'critical', 'error', 'warning', 'info', 'debug', 'ignore'
  # 'ignore' will cause the exception to not be reported at all.
  # config.exception_level_filters.merge!('MyCriticalException' => 'critical')

  # Custom Exceptions
  # begin
  #   foo = bar
  # rescue Exception => e
  #   Ratchetio.report_exception(e, ratchetio_request_data, ratchetio_person_data)
  # end  
  # logs at the 'warning' level. all levels: debug, info, warning, error, critical
  # Ratchetio.report_message("Unexpected input", "warning")
  # default level is "info"
  # Ratchetio.report_message("Login successful")
  # can also include additional data as a hash in the final param. :body is reserved.
  # Ratchetio.report_message("Login successful", "info", :user => @user)  
  
  # Enable asynchronous reporting (uses girl_friday or Threading if girl_friday
  # is not installed)
  # config.use_async = true
  # Supply your own async handler:
  # config.async_handler = Proc.new { |payload|
  #  Thread.new { Ratchetio.process_payload(payload) }
  # }
end
