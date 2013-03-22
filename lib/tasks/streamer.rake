namespace :stream do
  task :run => :environment do
    EM.run {
      $restforce.subscribe 'ChallengeFireHose' do |message|
      	Rails.logger.info "[INFO][STREAM]Received message #{message['sobject']['Challenge_Id__c']}"
	      Resque.enqueue(SyncChallengeToRedis, message['sobject']['Challenge_Id__c'])
      end
    }
  end
end