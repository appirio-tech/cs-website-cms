class MarketingUpdateNewMember

  @queue = :marketing_update_queue
  def self.perform(access_token, membername, campaign_source, campaign_medium, campaign_name)

  	Rails.logger.info "[INFO][Resque]==== Updating #{membername} with marketing info"

		ApiModel.access_token = access_token
  	results = Account.new(User.new(:username => membername)).process_marketing(campaign_source,campaign_medium,campaign_name)

    log_type = 'FATAL'
    log_type = 'INFO' if results.success

    Rails.logger.info "[#{log_type}][Resque]==== Marketing results for #{membername}: #{results.message}"
    
  end
  
end