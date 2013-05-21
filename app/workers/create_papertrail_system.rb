class CreatePapertrailSystem
  
  @queue = :create_papertrail_system
  def self.perform(membername, email, challenge_id, challenge_participant_id)

    account = {
      :name => membername, 
      :email => email,
      :papertrail_id => membername
    }

    options = { 
      :body => { :account => account }.to_json,
      :headers => api_request_headers   
    }

    account_create_results = HTTParty.post("#{ENV['THURGOOD_API_URL']}/loggers/account/create", options)
    raise "Could not create Papertrail account for #{membername} and challenge #{challenge_id}" if account_create_results.has_key?('error') 
    Rails.logger.info "[Resque][PT]==== Created Papertrail account: #{account_create_results['response']['papertrail_id']}"
    puts "[Resque][PT]==== Created Papertrail account: #{account_create_results['response']['papertrail_id']}"

    # create the system
    system = {
      :name => "Challenge-#{challenge_id}-#{challenge_participant_id}", 
      :logger_account_id => account_create_results['response']['id'],
      :papertrail_account_id => membername,
      :papertrail_id => "#{membername}-#{challenge_participant_id}"
    }

    options = { 
      :body => { :system => system }.to_json,
      :headers => api_request_headers    
    }  

    sender_create_results = HTTParty.post("#{ENV['THURGOOD_API_URL']}/loggers/system/create", options)
    raise "Could not create Papertrail sender for #{membername} and challenge #{challenge_id}: #{sender_create_results['error_description']}" if sender_create_results.has_key?('error') 
    Rails.logger.info "[Resque][PT]==== Created Papertrail system: #{sender_create_results['response']['papertrail_id']}"
    puts "[Resque][PT]==== Created Papertrail system: #{sender_create_results['response']['papertrail_id']}"

  rescue Exception => e
    Rails.logger.fatal "[Resque][PT][FATAL]==== #{e.message}"
    puts "[Resque][PT][FATAL]==== #{e.message}"
  end

  def self.api_request_headers
    {
      'Authorization' => 'Token token="'+ENV['THURGOOD_API_KEY']+'"',
      'Content-Type' => 'application/json'
    }
  end    
  
end