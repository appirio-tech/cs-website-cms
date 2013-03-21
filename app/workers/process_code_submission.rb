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
		results = participant.create_deliverable(challenge_id, membername, {data: deliverable})

		if results.success
			Rails.logger.info "[INFO][Resque]==== Created submission deliverable for submission #{challenge_submission_id}: #{results.message}"
			deploy_status = participant.deploy_deliverable(results.message)
			Rails.logger.info "[INFO][Resque]==== Squirrelforce deployment status for submission deliverable #{results.message}: #{deploy_status.to_yaml}"
		else
			Rails.logger.fatal "[FATAL][Resque]==== Could not create submission deliverable for submission #{challenge_submission_id}: #{results.message}"
		end
  
  end
  
end