class CreatePapertrailSystem
  
  @queue = :create_papertrail_system
  def self.perform(membername, email, challenge_id, challenge_participant_id)

    account = {
      :name => membername, 
      :email => email,
      :papertrail_id => membername
    }

    options = { 
      :body => { :account => account }    
    }

    set_api_request_headers
    account_create_results = HTTParty.post("#{ENV['THURGOOD_API_URL']}/loggers/account/create", options)['response']
    Rails.logger.info "[Resque][PT]==== Create Papertrail account: #{account_create_results.to_yaml}"
    puts "[Resque][PT]==== Create Papertrail account: #{account_create_results.to_yaml}"

    raise account_create_results.error_description if account_create_results.has_key?('error')

    # create the system
    system = {
      :name => "Challenge-#{challenge_id}-#{challenge_participant_id}", 
      :logger_account_id => account_create_results['id'],
      :papertrail_account_id => membername,
      :papertrail_id => "#{membername}-#{challenge_participant_id}"
    }

    options = { 
      :body => { :system => system }    
    }  

    set_api_request_headers
    sender_create_results = HTTParty.post("#{ENV['THURGOOD_API_URL']}/loggers/system/create", options)['response']
    raise "Could not create Papertrail sender for #{membername} and challenge #{challenge_id}" unless sender_create_results
    Rails.logger.info "[Resque][PT]==== Create Papertrail sender: #{sender_create_results.to_yaml}"
    puts "[Resque][PT]==== Create Papertrail sender: #{sender_create_results.to_yaml}"  

  rescue Exception => e
    Rails.logger.fatal "[Resque][PT][FATAL]==== Error create Papertrail account or system: #{e.message}"
    puts "[Resque][PT][FATAL]==== Error create Papertrail account or system: #{e.message}"
  end

  def self.set_api_request_headers
    {
      'Authorization' => 'Token token="'+ENV['THURGOOD_API_KEY']+'"',
      'Content-Type' => 'application/json'
    }
  end      
  
end