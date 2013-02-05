class ChallengesController < ApplicationController

  before_filter :set_nav_tick

  # list of challenges including open/closed status & pagination
  def index
    @challenges = Challenge.all params[:filters], params[:page]
    puts @challenges.first.to_yaml
  end

  def show
    @challenge = Challenge.find params[:id]
    #render :json => @challenge.comments
  end

  # rss feed based upon the selected platform, technology & category
  def feed

  end 

  def update
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

end
