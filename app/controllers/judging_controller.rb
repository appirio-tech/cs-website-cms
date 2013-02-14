class JudgingController < ApplicationController
	before_filter :authenticate_user!

	def outstanding_reviews
	
	end

	def scorecard

	end

	def judging_queue
		@member = Member.find(current_user.username, { fields: 'id,total_wins' })
		@challenges = Challenge.judging_queue
		if @member.total_wins < 3
			@challenges = []
			flash[:info] = 'Sorry... you must have won at least three CloudSpokes challenges before you are eligible to judge.' 
		end
	end

  def add_judge
    render :text => Challenge.add_judge(params[:challenge_id], current_user.username)
  end    

end
