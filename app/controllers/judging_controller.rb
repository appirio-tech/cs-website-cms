class JudgingController < ApplicationController

	def outstanding_reviews
	
	end

	def scorecard

	end

	def judging_queue
		@challenges = Challenge.judging_queue
		render :json => @challenges.first
	end

end
