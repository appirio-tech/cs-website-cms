class SyncAllChallengesToRedis
  
  @queue = :sync_all_challenges_to_redis
  def self.perform
		ApiModel.access_token = RestforceUtils.access_token(:admin)
		all_challenges = RestforceUtils.query_salesforce('select challenge_id__c from challenge__c')

		all_challenges.each do |c|
			Rails.logger.info "[INFO][Resque] Syncing challenge #{c.challenge_id} to redis"
			begin
				challenge = Challenge.find c.challenge_id
				challenge.redis_sync	
			rescue Exception => e
				Rails.logger.info "[INFO][Resque]Could not sync challenge #{c.challenge_id} - #{e.message}"
			end
		end
  end
  
end