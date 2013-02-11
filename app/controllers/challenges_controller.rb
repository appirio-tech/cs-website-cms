class ChallengesController < ApplicationController

  before_filter :set_nav_tick
  before_filter :authenticate_user!, :only => [:preview, :preview_survey, :review, :register, 
    :watch, :agree_tos, :submission, :submission_view_only, :new_comment, 
    :toggle_discussion_email, :participant_submissions]
  before_filter :current_user_participant, :only => [:show, :preview]
  before_filter :restrict_to_challenge_admins, :only => [:submissions]

  def index
    # if the user passed over the technology as a link from another page
    params[:filters] = {:technology => params[:technology] } if params[:technology] 
    @challenges = Challenge.all params[:filters]
  end

  def show
    @challenge = current_challenge
  end

  def preview
    @challenge = current_challenge
    if @challenge.preview? and current_user.challenge_admin?(current_challenge)
      render 'show'
    else
      redirect_to challenge_path, :alert => 'You are not able to preview this challenge as it is either 
        already available on the site or you do not have admin rights to it.' 
    end
  end  

  def participants
    @challenge = Challenge.find params[:id]
  end

  def register
    redirect_to challenge_path, :error => 'Registration is closed for this challenge.' if current_challenge.closed_for_registration?
    # if default tos, let them register
    if current_challenge.uses_default_tos?
      results = Participant.change_status(params[:id], current_user.username, 
        {:status => 'Registered'})
      flash[:notice] = "You have been registered for this challenge." if results.success.to_bool
      flash[:error]  = "There was an error registering you for this challenge." if !results.success.to_bool
      redirect_to challenge_path(params[:id])
    # challenge has it's own terms. show and make them register
    else
      @terms = CsPlatform.tos(current_challenge.tos)
    end

  end

  def agree_tos
    results = Participant.change_status(params[:id], current_user.username, 
      {:status => 'Registered'})
    flash[:notice] = "You have been registered for this challenge." if results.success.to_bool
    flash[:error]  = "There was an error registering you for this challenge." if !results.success.to_bool
    redirect_to challenge_path(params[:id])
  end

  def watch
    results = Participant.change_status(params[:id], current_user.username, 
      {:status => 'Watching'})
    flash[:notice] = "You are now watching this challenge." if results.success.to_bool
    flash[:error]  = "There was an error adding you to the watch list." if !results.success.to_bool
    redirect_to challenge_path(params[:id])
  end  

  def submissions
    @challenge = current_challenge
  end  

  def results
    @challenge = current_challenge
  end  

  def comment
    comments = params[:comment][:comments]

    unless verify_recaptcha
      flash[:unsaved_comments] = comments
      return redirect_to :back, :alert => 'There was an error with the recaptcha code below. Please resubmit your comment.'
    end      

    if comments.length > 2000
      flash[:unsaved_comments] = comments
      return redirect_to :back, :alert => 'Comments cannot be longer than 2000 characters. Please try again.'
    end

    challenge = Challenge.find params[:id]
    params[:comment][:comments] = params[:comment][:comments].gsub(/\n/, "<br/>")
    resp = challenge.create_comment(params[:comment])
    if resp.success == "true"
      redirect_to challenge_path(challenge), :notice => 'Comment successfully posted to discussions.'
    else
      flash[:unsaved_comments] = comments
      return redirect_to :back, :alert => "[#{resp.message}] There was an error posting your comments. Please try again."
    end
  end

  private
  
    def current_challenge
      @current_challenge ||= Challenge.find params[:id]
    end

    def restrict_to_challenge_admins
      redirect_to challenge_path, :alert => 'You do not have access to this page.' if !current_user.challenge_admin?(current_challenge) 
    end

    def set_nav_tick
      @challenges_tick = true
    end

    def current_user_participant
      @current_member_participant = Participant.current_status(params[:id], current_user.username) if user_signed_in?
    end

end
