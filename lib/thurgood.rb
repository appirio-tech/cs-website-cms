module Thurgood

	def self.send_message(job_id, text)

    message = {
      :text => text, 
      :sender => 'cloudspokes'
    }

    options = { 
      :body => { :message => message }.to_json,
      :headers => api_request_headers   
    }
  	
  	# create the new thurgood job
  	Hashie::Mash.new(HTTParty.post("#{ENV['THURGOOD_API_URL']}/jobs/#{job_id}/message", options))
	
	end

  def self.api_request_headers
    {
      'Authorization' => 'Token token="'+ENV['THURGOOD_API_KEY']+'"',
      'Content-Type' => 'application/json'
    }
  end    	

end