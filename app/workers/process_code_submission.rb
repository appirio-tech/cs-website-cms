class ProcessCodeSubmission
  
  @queue = :process_code_submission
  def self.perform(access_token, challenge_id, membername, challenge_submission_id)

  	puts "[INFO][Resque]==== Processing code for submission #{challenge_submission_id}" 	

  	puts "access_token #{access_token}"
  	puts "challenge_id #{challenge_id}"
  	puts "membername #{membername}"
  	puts "challenge_submission_id #{challenge_submission_id}"

		ApiModel.access_token = access_token
		# get the participant
		participant = Participant.find_by_member(challenge_id, membername)
		# get this submission
		submission = participant.find_submission(challenge_id, membername, challenge_submission_id)

		puts "submission: #{submission.to_yaml}"

		deliverable = SubmissionDeliverable.new
		deliverable.type = submission.type
		deliverable.comments = submission.comments
		deliverable.url = submission.url

		#hardcoded for sfdc for now
		deliverable.hosting_platform = 'Salesforce.com'
		deliverable.language = 'Apex'

		puts "deliverable: #{deliverable.to_yaml}"

		# create the new deliverables record
		results = participant.create_deliverable(challenge_id, membername, {data: deliverable})

		if results.success
			puts "[INFO][Resque]==== Created submission deliverable for submission #{challenge_submission_id}: #{results.message}"
			deploy_status = participant.deploy_deliverable(results.message)
			puts "[INFO][Resque]==== Squirrelforce deployment status for submission deliverable #{results.message}: #{deploy_status.to_yaml}"
		else
			puts "[FATAL][Resque]==== Could not create submission deliverable for submission #{challenge_submission_id}: #{results.message}"
		end
  
  end
  
end