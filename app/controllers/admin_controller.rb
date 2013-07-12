class AdminController < ApplicationController
	http_basic_authenticate_with :name => ENV['WEB_ADMIN_USERNAME'], :password => ENV['WEB_ADMIN_PASSWORD']

	def redis_challenge
		render :json => Challenge.redis_find(params[:challenge_id])
	end

	def redis_sync_all
		Challenge.redis_sync_all
		redirect_to :back, :notice => 'All challenges being synced to redis.'
	end

	def redis_sync_challenge
		c = Challenge.find(params[:id])
		c.redis_sync
		render :json => c
	end

	def redis_search
		results = Challenge.search participants: 2
		render :json => results
	end

	def blog_fodder
		@challenge = Challenge.find params[:challenge_id]
	end	

	def unleash_squirrel
  	deliverable = RestforceUtils.query_salesforce("select Id, 
  		Challenge_Participant__r.Member__r.Name, 
  		Challenge_Participant__r.Challenge__r.Challenge_Id__c 
  		from Submission_Deliverable__c where id = '#{params[:submission_deliverable_id]}'").first

		render :text => "Kicked off Thurgood process for submission #{params[:submission_deliverable_id]} 
		for #{deliverable.challenge_participant__r.member__r.name} for challenge 
			#{deliverable.challenge_participant__r.challenge__r.challenge_id}."
	  Resque.enqueue(ProcessCodeSubmission, admin_access_token, 
	  	deliverable.challenge_participant__r.challenge__r.challenge_id, 
	    deliverable.challenge_participant__r.member__r.name,
	    params[:submission_deliverable_id])
		rescue Exception => e
			render :text => e.message
	end

end
