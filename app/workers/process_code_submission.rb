class ProcessCodeSubmission
  
  @queue = :process_code_submission
  def self.perform(access_token, challenge_id, membername, challenge_submission_id)
    Rails.logger.info "[INFO][Resque]==== Processing code for challenge_submission_id #{challenge_submission_id}" 	
    Rails.logger.info "[INFO][Resque]==== challenge_id #{challenge_id}"
    Rails.logger.info "[INFO][Resque]==== membername #{membername}"
    # access token is not needed
    Thurgood.process_submission(challenge_id, membername, challenge_submission_id)
  end
  
end