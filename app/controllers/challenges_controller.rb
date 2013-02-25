require 'will_paginate/array'

class ChallengesController < ApplicationController

  before_filter :set_nav_tick
  before_filter :authenticate_user!, :only => [:preview, :preview_survey, :review, :register, 
    :watch, :agree_tos, :submission, :submissions, :submission_view_only, :comment, 
    :toggle_discussion_email, :submit, :participant_submissions, :results, :results_scorecard]
  before_filter :load_current_challenge, :only => [:show, :preview, :participants, 
    :submit, :submit_url, :submissions, :results, :scorecard, :comment]
  before_filter :current_user_participant, :only => [:show, :preview, :submit, :submit_url, 
    :submit_file, :submit_url_or_file_delete, :results, :results_scorecard, :scorecard, :comment]
  before_filter :restrict_to_challenge_admins, :only => [:submissions]
  before_filter :challenge_must_be_open, :only => [:register, :watch, :agree_tos, :submit_url, :submit_file]
  before_filter :must_be_registered, :only => [:submit]

  def index
    # if the user passed over the technology as a link from another page
    params[:filters] = {:technology => params[:technology] } if params[:technology] 
    params[:filters] = massage_old_params if params[:category]
    @challenges = Challenge.all params[:filters]

    @platforms = all_platforms
    @technologies = all_technologies
    @categories = all_categories
  end

  def recent
    @challenges = Challenge.recent
    @challenges = @challenges.paginate(:page => params[:page], :per_page => 20)
  end  

  def show
    @comments = @challenge.comments
    Resque.enqueue(IncrementChallengePageView, @challenge.challenge_id) unless current_user && current_user.challenge_admin?(@challenge)
  end

  def preview
    if @challenge.preview? and current_user.challenge_admin?(@challenge)
      @comments = []
      render 'show'
    else
      redirect_to challenge_path, :alert => 'You are not able to preview this challenge as it is either 
        already available on the site or you do not have admin rights to it.' 
    end
  end  

  def register
    redirect_to challenge_path, :error => 'Registration is closed for this challenge.' if current_challenge.closed_for_registration?
    # if default tos, let them register
    if current_challenge.uses_default_tos?
      results = Participant.change_status(params[:id], current_user.username, 
        {:status => 'Registered'})
      flash[:notice] = "You have been registered for this challenge." if results.success.to_bool
      flash[:error]  = "Could not register you for this challenge: #{results.message}" if !results.success.to_bool
      redirect_to challenge_path(params[:id])
    # challenge has it's own terms. show and make them register
    else
      @terms = CsPlatform.tos(current_challenge.tos)
    end
  end

  def participants
    @participants = @challenge.participants
  end

  def search
    @challenges = Challenge.search params[:search]
    @platforms = all_platforms
    @technologies = all_technologies
    @categories = all_categories
    @communities = Community.names
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
    flash[:error]  = "Could not add you to the watch list for this challenge: #{results.message}" if !results.success.to_bool
    redirect_to challenge_path(params[:id])
  end  

  def submit
    @submissions = @current_member_participant.current_submissions(params[:id])
  end

  def submit_url
    if uri?(params[:url_submission][:link])
      submission_results = @current_member_participant.save_submission_file_or_url(@challenge.challenge_id, params[:url_submission])
      if submission_results.success.to_bool
        flash[:notice] = "URL successfully submitted for this challenge."
      else
        flash[:error] = "There was an error submitting your URL. Please check it and submit it again."
      end
    else
      flash[:error] = "Please enter a valid URL."
    end
    redirect_to :back
  end  

  def submit_file
    if params[:file].nil?
      flash[:error] = "Please upload a valid file."
    else
      begin
        file = params[:file][:file_name]
        storage ||= begin
          fog = Fog::Storage.new(
            :provider                 => 'AWS',
            :aws_secret_access_key    => ENV['AWS_SECRET'],
            :aws_access_key_id        => ENV['AWS_KEY']
          )
          fog.directories.get(ENV['AWS_BUCKET'])
        end
        uploaded_file = storage.files.create(
          :key    => "challenges/#{params[:id]}/#{current_user.username}/#{file.original_filename}",
          :body   => file.read,
          :public => true
        )  
        complete_url = "https://s3.amazonaws.com/#{ENV['AWS_BUCKET']}/challenges/#{params[:id]}/#{current_user.username}/#{file.original_filename}"
        submission_params = {:link => complete_url, :comments => params[:file_submission][:comments]}    
        submission_results = @current_member_participant.save_submission_file_or_url(params[:id], submission_params)
        if submission_results.success.to_bool
          flash[:notice] = "File successfully uploaded and submitted for this challenge."
        else
          flash[:error] = "There was an error submitting your file. Please check it and submit it again."
        end
      rescue => e    
        flash[:error] = "There was an error submitting your File: #{e.message}. Please check it and submit it again."
      end
    end
    redirect_to :back
  end  

  def submit_url_or_file_delete
    submission_results = @current_member_participant.delete_submission(params[:id], params[:submissionId])
    if submission_results.success.to_bool
      flash[:notice] = "Successfully deleted your URL or File from your submission."
    else
      flash[:error] = "There was an error deleting your URL or File. Please try again."
    end
    redirect_to :back
  end  

  def submissions
    @deliverables = @challenge.submission_deliverables
  end  

  # if the status is NOT 'winner selected' or 'no winner selected' AND the user is not a 
  # challegne admin with a status of 'review - pending', redirect them
  def results
    unless ['winner selected','no winner selected'].include?(@challenge.status.downcase) || 
      (current_user.challenge_admin?(@challenge) && @challenge.status.downcase == 'review - pending')
      redirect_to challenge_path, :alert => 'Results are not available at this time.' 
    end
  end  

  def results_scorecard
    @participant = Participant.find_by_member(params[:id], params[:participant])
    @submissions = @participant.current_submissions(params[:id])
    scorecard_questions = Judging.participant_scorecard(@participant.id, params[:judge])
    @scorecard = JSON.parse(scorecard_questions.keys.first) 
    gon.scorecard = scorecard_questions.values.first
  rescue Exception => e
    redirect_to :not_found
  end

  def scorecard
    @scorecard_group = Challenge.scorecard_questions(params[:id])
  end  

  def comment
    comments = params[:comment][:comments]

    if current_user.use_captcha?(@challenge, @current_member_participant)
      unless verify_recaptcha
        flash[:unsaved_comments] = comments
        return redirect_to :back, :alert => 'There was an error with the recaptcha code below. Please resubmit your comment.'
      end 
    end     

    if comments.length > 2000
      flash[:unsaved_comments] = comments
      return redirect_to :back, :alert => 'Comments cannot be longer than 2000 characters. Please try again.'
    end

    params[:comment][:comments] = params[:comment][:comments].gsub(/\n/, "<br/>")
    resp = @challenge.create_comment(params[:comment])
    if resp.success.to_bool
      redirect_to challenge_path(@challenge), :notice => 'Comment successfully posted to discussions.'
    else
      flash[:unsaved_comments] = comments
      return redirect_to :back, :alert => "[#{resp.message}] There was an error posting your comments. Please try again."
    end
  end  

  private
  
    def current_challenge
      @current_challenge ||= Challenge.find params[:id]
    end

    def all_platforms
      Rails.cache.fetch('all-platforms', :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do
        Platform.names
      end
    end    

    def all_technologies
      Rails.cache.fetch('all-technologies', :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do
        Technology.names
      end
    end   

    def all_categories
      Rails.cache.fetch('all-categories', :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do
        Category.names
      end
    end     

    def load_current_challenge
      @challenge = current_challenge    
    end

    def restrict_to_challenge_admins
      redirect_to challenge_path, :alert => 'You do not have access to this page.' if !current_user.challenge_admin?(current_challenge) 
    end

    def set_nav_tick
      @challenges_tick = true
    end

    def current_user_participant
      @current_member_participant = Participant.find_by_member(params[:id], current_user.username) if user_signed_in?
    end

    def challenge_must_be_open
      redirect_to challenge_path, :alert => 'This challenge is no longer open.' unless current_challenge.open? || current_user_participant.override_submission_upload
    end  

    def must_be_registered
      redirect_to challenge_path, :alert => 'You must be registered for this challenge before can submit.' if ['not registered','watching'].include?(@current_member_participant.status.downcase)
    end    

    # temp -- to support old URLs like /challenges/index?category=JavaScript
    def massage_old_params
      puts "massaging old params"
      old_platforms = ['aws','box','cloud foundry','database.com','docusign','facebook','google',
        'heroku','mobile','other','salesforce.com']
      old_technologies = ['java','javascript','other','ruby','objective-c','php','node','node.js',
        'ios','android','apex','visualforce','redis','python']

      return {:platform => params[:category] } if old_platforms.include?(params[:category].downcase)
      return {:technology => params[:category] } if old_technologies.include?(params[:category].downcase)
    end 

    def uri?(string)
      uri = URI.parse(string)
      %w( http https ).include?(uri.scheme)
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
    end    

end
