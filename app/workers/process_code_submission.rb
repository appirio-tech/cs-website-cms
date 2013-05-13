class ProcessCodeSubmission
  
  @queue = :process_code_submission
  def self.perform(access_token, challenge_id, membername, challenge_submission_id)

  	Rails.logger.info "[INFO][Resque]==== Processing code for submission #{challenge_submission_id}" 	
  	Rails.logger.info "[INFO][Resque]==== access_token #{access_token}"
  	Rails.logger.info "[INFO][Resque]==== challenge_id #{challenge_id}"
  	Rails.logger.info "[INFO][Resque]==== membername #{membername}"
  	Rails.logger.info "[INFO][Resque]==== challenge_submission_id #{challenge_submission_id}"

		ApiModel.access_token = access_token
		# get the participant
		participant = Participant.find_by_member(challenge_id, membername)
		# get this submission
		submission = participant.find_submission(challenge_id, membername, challenge_submission_id)

		Rails.logger.info "[INFO][Resque]==== submission: #{submission.to_yaml}"

		deliverable = SubmissionDeliverable.new
		deliverable.type = submission.type
		deliverable.comments = submission.comments
		deliverable.url = submission.url

		#hardcoded for sfdc for now
		deliverable.hosting_platform = 'Salesforce.com'
		deliverable.language = 'Apex'

		# create the new deliverables record
		results = participant.create_deliverable(challenge_id, membername, deliverable)

		if results.success
			sfdc_update_results = create_thurgood_job(deliverable, participant.id, membername)
	   	if @@sfdc_update_results.success
	   		submit_thurgood_job(participant.id)
	   	else
		   	Rails.logger.fatal "[FATAL][Resque]==== Error updating participant with job_id: #{update_results.message}" 
		  end

			Rails.logger.info "[INFO][Resque]==== Created submission deliverable for submission #{challenge_submission_id}: #{results.message}"
			deploy_status = participant.deploy_deliverable(results.message)
			Rails.logger.info "[INFO][Resque]==== Thurgood deployment status for submission deliverable #{results.message}: #{deploy_status.to_yaml}"
		else
			Rails.logger.fatal "[FATAL][Resque]==== Could not create submission deliverable for submission #{challenge_submission_id}: #{results.message}"
		end

  rescue Exception => e
		Rails.logger.fatal "[FATAL][Resque]==== Process code submission exception: #{e.message}"
  end

  private

  	def self.create_thurgood_job(deliverable, participant_id, membername)

			# get the member's email address
	    email = RestforceUtils.query_salesforce("select email__c from member__c 
	      where name = '#{membername}'").first.email

	  	payload = { :job =>
		  	{
		  		:user_id => "cs-#{membername}", 
		  		:email => email, 	  		
		  		:language => deliverable.language.downcase, 
		  		:platform => deliverable.hosting_platform.downcase, 
		  		:code_url => deliverable.url
		  	} 
		  }
	  	options = { 
	  		:body => payload
	  	}	 
	  	set_api_request_headers
	  	
	  	# create the new thurgood job
	  	@@new_job = Hashie::Mash.new(HTTParty.post("#{ENV['THURGOOD_API_URL']}/jobs", options)['response'])
			Rails.logger.info "[INFO][Resque]==== Created new Thurgood job: #{@@new_job.to_yaml}"

	   	# write the participant with the job id
	   	@@sfdc_update_results = Hashie::Mash.new(RestforceUtils.update_in_salesforce('Challenge_Participant__c',
	   		:id => participant_id, :thurgood_job_id__c => @@new_job.job_id))
	   	Rails.logger.info "[INFO][Resque]==== Update Thurgood job for participant in sfdc: #{@@sfdc_update_results.to_yaml}"

  	end  

  	def self.submit_thurgood_job(participant_id)
  		set_api_request_headers
	  	submit_job = Hashie::Mash.new(HTTParty.get("#{ENV['THURGOOD_API_URL']}/jobs/#{@@new_job.job_id}/submit?system_papertrail_id=#{participant_id}")['response'])
	  	Rails.logger.info "[INFO][Resque]==== Submitted Thurgood job: #{submit_job.to_yaml}"
  	end

	  def self.set_api_request_headers
	    {
	      'Authorization' => 'Token token="'+ENV['THURGOOD_API_KEY']+'"',
	      'Content-Type' => 'application/json'
	    }
	  end    	
  
end