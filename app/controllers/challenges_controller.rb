class ChallengesController < ApplicationController

  def closed
    # @challenges = Challenge.closed
    # render :json => @challenges
  end

  def recent
    @challenges = Challenge.recent
    render :json => @challenges
  end

  def comments
  end

  def registrants
    @participants = Challenge.find params[:id].participantsrender :json => @challenges
    render :json => @participants
  end

  def survey
  end

  def index
    @challenges = Challenge.all params[:filters], params[:page]
  end

  def search
    @challenges = Challenge.search params[:search]
    render :json => @challenges
  end  

  def show
    @challenge = Challenge.find params[:id]
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
end
