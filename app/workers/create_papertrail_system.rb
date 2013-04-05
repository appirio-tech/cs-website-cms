class CreatePapertrailSystem
  
  @queue = :create_papertrail_system
  def self.perform(membername, email, challenge_id, challenge_participant_id)

  	auth = {
  		:username => ENV['PAPERTRAIL_DIST_USERNAME'], 
  		:password => ENV['PAPERTRAIL_DIST_PASSWORD']
  	}
  	
  	# create the user's account
  	user = {
  		:id => membername, 
  		:email => email
  	}
  	payload = {
  		:id => membername, 
  		:name => membername, 
  		:user => user, 
  		:plan => 'free'
  	}
  	options = { 
  		:body => payload, 
  		:basic_auth => auth 
  	}

  	account_create_results = HTTParty.post("https://papertrailapp.com/api/v1/distributors/accounts", options)
  	Rails.logger.info "[Resque][PT]==== Create Papertrail account: #{account_create_results}"
  	puts "[Resque][PT][PUTS]==== Create Papertrail account: #{account_create_results}"

  	# create the system / log sender
  	payload = {
  		:id => challenge_participant_id, 
  		:name => "Challenge-#{challenge_id}-#{challenge_participant_id}", 
  		:account_id => membername
  	}
  	options = { 
  		:body => payload, 
  		:basic_auth => auth 
  	}  	

  	sender_create_results = HTTParty.post("https://papertrailapp.com/api/v1/distributors/systems", options)
  	Rails.logger.info "[Resque][PT]==== Create Papertrail sender: #{sender_create_results}"
  	puts "[Resque][PT][PUTS]==== Create Papertrail sender: #{sender_create_results}"

  end
  
end