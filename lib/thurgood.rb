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

  def self.process_submission(challenge_id, membername, challenge_submission_id)

    # get an admin token for the get requests. fails without an admin token. not sure why.
    admin_access_token = RestforceUtils.access_token(:admin)

    submission = RestforceUtils.query_salesforce("select Id, Challenge__c, Challenge_Participant__c, 
      Type__c, URL__c, Language__c 
      from Challenge_Submission__c 
      where id = '#{challenge_submission_id}'", admin_access_token).first

    unless ['apex / visualforce', 'java'].include?(submission.language.downcase)
      Rails.logger.info "[INFO][Resque]==== Deliverable not submitted to Thurgood. '#{submission.language}' not a supported type."
      return
    end

    ApiModel.access_token = admin_access_token
    participant = Participant.find_by_member(challenge_id, membername)

    Rails.logger.info "[INFO][Resque]==== participant: #{participant.to_yaml}"
    Rails.logger.info "[INFO][Resque]==== submission: #{submission.to_yaml}"
    
    deliverable = SubmissionDeliverable.new
    deliverable.type = submission.type
    deliverable.comments = submission.comments
    deliverable.url = submission.url

    # only supports sfdc and java
    if submission.language.downcase == 'apex / visualforce'
      deliverable.language = 'Apex'
      deliverable.hosting_platform = 'Salesforce.com'
    elsif submission.language.downcase == 'java'
      deliverable.language = 'Java'
      deliverable.hosting_platform = 'Heroku'
    end
    Rails.logger.info "[INFO][Resque]==== deliverable: #{deliverable.to_yaml}"    

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

      submit_job = Hashie::Mash.new(HTTParty.put("#{ENV['THURGOOD_API_URL']}/jobs/#{@@new_job.job_id}/submit", options))
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