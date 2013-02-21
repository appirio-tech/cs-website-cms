class ProcessReferral
  
  @queue = :process_referral
  def self.perform(access_token, referral_id_or_username, converted_member_name)

  	Rails.logger.info "[INFO][Resque]==== Marking #{converted_member_name} as referred by #{referral_id_or_username}" 	

		ApiModel.access_token = access_token
    results = Account.new(User.new(:username => converted_member_name)).process_referral(referral_id_or_username)

    log_type = 'FATAL'
    log_type = 'INFO' if results.success

    Rails.logger.info "[#{log_type}][Resque]==== Referral results for #{converted_member_name}: #{results.message}"
  
  end
  
end