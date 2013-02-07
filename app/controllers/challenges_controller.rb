class ChallengesController < ApplicationController

  before_filter :set_nav_tick
  # before_filter :authenticate_user!
  before_filter :current_user_participant, :only => [:show]

  # list of challenges including open/closed status & pagination
  def index
    @challenges = Challenge.all params[:filters], params[:page]
  end

  def show
    @challenge = Challenge.find params[:id]
    puts @challenge.assets.to_yaml
  end

  # rss feed based upon the selected platform, technology & category
  def feed

  end 

  def update
  end

  def participants
    @challenge = Challenge.find params[:id]
  end

  # TODO - MAKE SURE THEY AGREE TO TOS
  def register
    results = Participant.change_status(params[:id], current_user.username, 
      {:status => 'Registered'})
    flash[:notice] = "You have been registered for this challenge." if results.success.eql?('true')
    flash[:alert]  = "There was an error registering you for this challenge." if results.success.eql?('false')
    redirect_to challenge_path(params[:id])
  end

  def watch
    results = Participant.change_status(params[:id], current_user.username, 
      {:status => 'Watching'})
    flash[:notice] = "You are now watching this challenge." if results.success.eql?('true')
    flash[:alert]  = "There was an error adding you to the watch list." if results.success.eql?('false')
    redirect_to challenge_path(params[:id])
  end  

  def comment
    comments = params[:comment][:comments]

    unless verify_recaptcha
      flash[:unsaved_comments] = comments
      flash[:alert] = "There was an error with the recaptcha code below. Please resubmit your comment."
      return redirect_to :back
    end      

    if comments.length > 2000
      flash[:unsaved_comments] = comments
      flash[:alert] = "Comments cannot be longer than 2000 characters. Please try again."        
      return redirect_to :back
    end

    @challenge = Challenge.find params[:id]
    resp = @challenge.create_comment(params[:comment])
    if resp.success == "true"
      flash[:notice] = "Comment is created successfully."
      redirect_to challenge_path(@challenge)
    else
      flash[:unsaved_comments] = comments
      flash[:alert] = "[#{resp.message}] There was an error posting your comments. Please try again."
      return redirect_to :back
    end
  end

  private

    def set_nav_tick
      @challenges_tick = true
    end

    def current_user_participant
      @current_member_participant = Participant.current_status(params[:id], current_user.username) if user_signed_in?
    end

end
