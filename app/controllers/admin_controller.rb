class AdminController < ApplicationController
	http_basic_authenticate_with :name => ENV['WEB_ADMIN_USERNAME'], :password => ENV['WEB_ADMIN_PASSWORD']

	def redis_challenge
		render :json => Challenge.redis_find(params[:challenge_id])
	end

	def redis_sync_all
		Challenge.redis_sync_all
		redirect_to :back, :notice => 'All challenges being synced to redis.'
	end

	def blog_fodder
		@challenge = Challenge.find params[:challenge_id]
	end	

end
