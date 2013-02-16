class JudgingController < ApplicationController
	before_filter :authenticate_user!

	def outstanding_reviews
		@scorecards = Judging.outstanding_reviews(current_user.username)
	end

	def scorecard
		@participant = Participant.find(params[:participant_id])
		@submissions = @participant.current_submissions(@participant.challenge.challenge_id)
		scorecard_questions = Judging.participant_scorecard(params[:participant_id], current_user.username)
		@scorecard = JSON.parse(scorecard_questions.keys.first)	
		gon.scorecard = scorecard_questions.values.first
	end

	def scorecard_save
		results  = Judging.save_scorecard(params[:participant_id], params[:answers], {
			:scored => params[:set_as_scored].to_bool, 
			:delete_scorecard => params[:delete_participant_submission].try(:to_bool),
			:judge_membername => current_user.username
		}) 
		puts results.to_yaml
		if results.success
			flash[:notice] = results.message
		else
			flash[:error] = results.message
		end
		redirect_to outstanding_reviews_path
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
