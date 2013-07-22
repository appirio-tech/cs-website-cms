class ProcessCodeSubmission
  
  @queue = :process_code_submission
  def self.perform(access_token, challenge_id, membername, challenge_submission_id)

    Rails.logger.info "[INFO][Resque]==== Processing code for submission #{challenge_submission_id}" 	
    Rails.logger.info "[INFO][Resque]==== access_token #{access_token}"
    Rails.logger.info "[INFO][Resque]==== challenge_id #{challenge_id}"
    Rails.logger.info "[INFO][Resque]==== membername #{membername}"
    Rails.logger.info "[INFO][Resque]==== challenge_submission_id #{challenge_submission_id}"

    supported_submission_type = false
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

    # only supports sfdc and java
    if submission.language.downcase == 'apex / visualforce'
      deliverable.language = 'Apex'
      deliverable.hosting_platform = 'Salesforce.com'
      supported_submission_type = true
    elsif submission.language.downcase == 'java'
      deliverable.language = 'Java'
      deliverable.hosting_platform = 'Heroku'
      supported_submission_type =  true
    end
    Rails.logger.info "[INFO][Resque]==== deliverable: #{deliverable.to_yaml}"

    # create the new deliverables record -- ONLY IF A SUPPORTED TYPE
    if supported_submission_type == true
      results = participant.create_deliverable(challenge_id, membername, deliverable)
      if results.success
        sfdc_update_results = create_thurgood_job(deliverable, participant.id, membername)
        if @@sfdc_update_results.success
          submit_thurgood_job(challenge_id, membername, participant.id)
        else
          Rails.logger.fatal "[FATAL][Resque]==== Error updating participant with job_id: #{sfdc_update_results.message}" 
        end
        Rails.logger.info "[INFO][Resque]==== Deployed submission deliverable for #{challenge_submission_id} to Thurgood: #{results.message}"
      else
        Rails.logger.fatal "[FATAL][Resque]==== Could not create submission deliverable for submission #{challenge_submission_id}: #{results.message}"
      end
    else
      Rails.logger.info "[INFO][Resque]==== Deliverable not submitted to Thurgood. Not supported type."
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
        :user_id => "#{membername}", 
        :email => email, 	  		
        :language => deliverable.language.downcase, 
        :platform => deliverable.hosting_platform.downcase, 
        :code_url => deliverable.url
        } 
      }
      options = { 
        :body => payload.to_json, 
        :headers => api_request_headers
      }	 
  	
      # create the new thurgood job
      @@new_job = Hashie::Mash.new(HTTParty.post("#{ENV['THURGOOD_API_URL']}/jobs", options)['response'])
      Rails.logger.info "[INFO][Resque]==== Created new Thurgood job: #{@@new_job.to_yaml}"

      # write the participant with the job id
      @@sfdc_update_results = Hashie::Mash.new(RestforceUtils.update_in_salesforce('Challenge_Participant__c',
        {:id => participant_id, :thurgood_job_id__c => @@new_job.job_id}, nil, :admin))
      Rails.logger.info "[INFO][Resque]==== Update Thurgood job for participant in sfdc: #{@@sfdc_update_results.to_yaml}"

    rescue Exception => e
      Rails.logger.fatal "[FATAL][Resque]==== Error creating Thurgood job: #{e.message}"
    end  

    def self.submit_thurgood_job(challenge_id, membername, participant_id)

      payload = {
        :system_papertrail_id => "#{membername}-#{participant_id}", 
        :challenge_id => challenge_id,
        :participant_id => participant_id
      }

      options = { 
        :body => { :options => payload }.to_json,
        :headers => api_request_headers 
      }  

      submit_job = Hashie::Mash.new(HTTParty.put("#{ENV['THURGOOD_API_URL']}/jobs/#{@@new_job.job_id}/submit", options)['response'])
      Rails.logger.info "[INFO][Resque]==== Submitted Thurgood job: #{submit_job.to_yaml}"

    rescue Exception => e
      Rails.logger.fatal "[FATAL][Resque]==== Error submitting Thurgood job: #{e.message}"	  	
    end

    def self.api_request_headers
      {
        'Authorization' => 'Token token="'+ENV['THURGOOD_API_KEY']+'"',
        'Content-Type' => 'application/json'
      }
    end    	
  
end