class JudgingController < ApplicationController
	before_filter :authenticate_user!

	def outstanding_reviews
		@scorecards = Judging.outstanding_reviews(current_user.username)
	end

	def scorecard
		flash.now[:alert] = 'This page should be complete by 2/15. Sorry for the inconvenience.'
	end

	def judging_queue
		@member = Member.find(current_user.username, { fields: 'id,total_wins' })
		@challenges = Judging.judging_queue
		if @member.total_wins < 3
			@challenges = []
			flash.now[:info] = 'Sorry... you must have won at least three CloudSpokes challenges before you are eligible to judge.' 
		end		
	end

  def add_judge
    render :text => Judging.add_judge(params[:challenge_id], current_user.username)
  end    

end
