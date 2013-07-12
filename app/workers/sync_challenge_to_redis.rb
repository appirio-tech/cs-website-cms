class SyncChallengeToRedis
  
  @queue = :sync_challenge_to_redis
  def self.perform(challenge_id)
  	puts "syncing challenge #{challenge_id} to redis"
		ApiModel.access_token = RestforceUtils.access_token(:admin)
		challenge = Challenge.find challenge_id
		challenge.redis_sync
  end
  
end