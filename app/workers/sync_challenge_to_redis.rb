class SyncChallengeToRedis
  
  @queue = :sync_challenge_to_redis
  def self.perform(challenge_id)
		ApiModel.access_token = RestforceUtils.access_token(:admin)
		challenge = Challenge.find challenge_id
		challenge.redis_sync
  end
  
end