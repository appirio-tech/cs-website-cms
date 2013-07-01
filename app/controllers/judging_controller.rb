class JudgingController < ApplicationController
  before_filter :authenticate_user!

  def outstanding_reviews
    @scorecards = Judging.outstanding_reviews(current_user.username)    
    respond_to do |format|
      format.html
      format.json { render :json => @scorecards }
    end     
  end

  def scorecard
    @participant = Participant.find(params[:participant_id])
    @challenge = Challenge.find(@participant.challenge.challenge_id)
    @submissions = @participant.current_submissions(@participant.challenge.challenge_id)
    scorecard_questions = Judging.participant_scorecard(params[:participant_id], current_user.username)
    @scorecard = JSON.parse(scorecard_questions.keys.first)	
    puts scorecard_questions.values.first.to_yaml
    gon.scorecard = scorecard_questions.values.first
  end

  def scorecard_save
    results  = Judging.save_scorecard(params[:participant_id], params[:answers], params[:comments], {
      :scored => params[:set_as_scored].to_bool, 
      :delete_scorecard => params[:delete_participant_submission].try(:to_bool),
      :judge_membername => current_user.username
    }) 
    if results.success
      flash[:notice] = results.message
      Resque.enqueue(SendMessageToThurgood, params[:participant_id], 
        "Scorecard submitted by #current_user.username") if params[:set_as_scored].to_bool
    else
      flash[:error] = results.message
    end
    redirect_to outstanding_reviews_path
  end

  def judging_queue
    @no_challenges_message = 'There are currently no challenges that are in need of judges. Please check back later.'

    @member = Member.find(current_user.username, { fields: 'id,total_wins,can_judge' })
    @member.can_judge = '' if !@member.can_judge
    @challenges = Judging.judging_queue

    if @member.total_wins < 10 && !@member.can_judge.include?('Override Minimum Wins')
      @challenges = []
      @no_challenges_message = 'Sorry... you must have won at least ten CloudSpokes challenges before you are eligible to judge.' 
    elsif @member.can_judge.include?('Banned')
      @challenges = []
      @no_challenges_message = 'Sorry... you are not able to judge challenges are this time.' 
    end	

    respond_to do |format|
      format.html
      format.json { render :json => @challenges }
    end

  end

  def add_judge
    render :text => Judging.add_judge(params[:challenge_id], current_user.username)
  end   

end
