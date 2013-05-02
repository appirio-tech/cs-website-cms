require 'will_paginate/array'
require 'digest/sha1'

class ChallengesController < ApplicationController

  before_filter :set_nav_tick
  before_filter :authenticate_user!, :only => [:preview, :preview_survey, :review, :register, 
    :watch, :agree_tos, :submission, :submissions, :submission_view_only, :comment, 
    :toggle_discussion_email, :submit, :participant_submissions, :results_scorecard, :appeals]
  before_filter :load_current_challenge, :only => [:show, :preview, :participants, 
    :submit, :submit_url, :submit_file, :submissions, :results, :scorecard, :comment, :survey,
    :appeals]
  before_filter :current_user_participant, :only => [:show, :preview, :submit, :submit_url, 
    :submit_file, :submit_url_or_file_delete, :results_scorecard, :scorecard, :comment, :survey]
  before_filter :restrict_to_challenge_admins, :only => [:submissions]
  before_filter :challenge_must_be_open, :only => [:register, :watch, :agree_tos, :submit_url, :submit_file]
  before_filter :must_be_registered, :only => [:submit]
  before_filter :redirect_advanced_search, :only => [:search]
  before_filter :restrict_appeallate_member, :only => [:appeals]
  after_filter :delete_particiapnt_cache, :only => [:register, :agree_tos, :watch, :submit_url, :submit_file]

  def index
    @title = 'Open Challenges'
    search_default_params
    # if the user passed over the technology as a link from another page
    params[:filters] = {:technology => params[:technology] } if params[:technology] 
    params[:filters] = massage_old_params if params[:category]
    @challenges = Challenge.all params[:filters]      
  end   

  def search
    @title = 'Challenge Search Results'
    search_default_params

    gon.adv_search_display = true
    gon.adv_search_status = params[:advanced][:status]
    gon.adv_search_order_by = params[:advanced][:order_by]
    @selected_sort_by = params[:advanced][:sort_by]
    @keyword = params[:advanced][:keyword]
    @min_money = params[:advanced][:min_money]
    @max_money = params[:advanced][:max_money]
    @min_participants = params[:advanced][:min_participants]
    @max_participants = params[:advanced][:max_participants]  
    @selected_community = params[:advanced][:community] 

    @selected_platforms = params[:advanced][:platforms] 
    @selected_technologies = params[:advanced][:technologies] 
    @selected_categories = params[:advanced][:categories] 

    @selected_platforms_all = false
    @selected_platforms_all = true if @selected_platforms.include?('All Platforms')
    @selected_technologies_all = false
    @selected_technologies_all = true if @selected_technologies.include?('All Technologies')
    @selected_categories_all = false
    @selected_categories_all = true if @selected_categories.include?('All Categories')  

    #downcase all of the platforms, technologies and categories for redis
    search_platforms = @selected_platforms.map{|i| i.downcase}
    search_technologies = @selected_technologies.map{|i| i.downcase}
    search_categories = @selected_categories.map{|i| i.downcase}

    options = {state: params[:advanced][:status], 
      query: @keyword,
      platforms: search_platforms, 
      technologies: search_technologies, 
      categories: search_categories,
      prize_money: {min: @min_money, max: @max_money},
      participants: {min: @min_participants, max: @max_participants},
      community: @selected_community.downcase,
      sort_by: @selected_sort_by,
      order: params[:advanced][:order_by]}

    # run the search in redis
    @challenges = Challenge.search options
    render 'index'
  end  

  def recent
    @challenges = Challenge.recent
    @challenges = @challenges.paginate(:page => params[:page], :per_page => 20)
  end  

  def show
    @comments = Rails.cache.fetch("comments-#{params[:id]}", :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do
      current_challenge.comments
    end
    # add rescue for local dev without redis running (for challenge participants)
    Resque.enqueue(IncrementChallengePageView, @challenge.challenge_id) unless current_user && current_user.challenge_admin?(@challenge)
  rescue Exception => e
    puts e.message
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

  def participants
    @participants = @challenge.participants
  end

  def register
    redirect_to challenge_path, :error => 'Registration is closed for this challenge.' if current_challenge.closed_for_registration?
    # if default tos, let them register
    if current_challenge.uses_default_tos?
      results = Participant.change_status(params[:id], current_user.username, 
        {:status => 'Registered'})
      if results.success.to_bool
        flash[:notice] = "You have been registered for this challenge." 
        Resque.enqueue(CreatePapertrailSystem, current_user.username, 
          current_user.email, current_challenge.challenge_id, 
          results.message) unless ENV['PAPERTRAIL_DIST_USERNAME'].nil?
      else
        flash[:error]  = "Could not register you for this challenge: #{results.message}"
      end
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
    flash[:error]  = "Could not add you to the watch list for this challenge: #{results.message}" if !results.success.to_bool
    redirect_to challenge_path(params[:id])
  end  

  def submit
    @submissions = @current_member_participant.current_submissions(params[:id])
  end

  def papertrail
    @member_name = current_user.username
    # used the passed participant id so judges, sponsors, etc. can view the logs
    if params[:participant_id]
      p = Participant.find(params[:participant_id])
      @member_name = p.member.name
    end
    @token = Digest::SHA1.hexdigest("#{@member_name}:#{@member_name}:#{ENV['PAPERTRAIL_DIST_SSO_SALT']}:#{Time.now.to_i}")
  end  

  def submit_url
    if uri?(params[:url_submission][:link])
      submission_results = @current_member_participant.save_submission_file_or_url(@challenge.challenge_id, params[:url_submission])
      if submission_results.success.to_bool
        flash[:notice] = "URL successfully submitted for this challenge."
        send_task_submission_notification if @challenge.challenge_type.downcase == 'task'
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
        submission_params = {:link => complete_url, :comments => params[:file_submission][:comments], :type => params[:file_submission][:type]}    
        submission_results = @current_member_participant.save_submission_file_or_url(params[:id], submission_params)
        if submission_results.success.to_bool
          flash[:notice] = "File successfully uploaded and submitted for this challenge."
          send_task_submission_notification if @challenge.challenge_type.downcase == 'task' 
          # kick off the squirrelforce process
          Resque.enqueue(ProcessCodeSubmission, admin_access_token, params[:id], 
            current_user.username, submission_results.message) if params[:file_submission][:type] == 'Code'
        else
          flash[:error] = "There was an error submitting your file. Please check it and submit it again."
        end
      rescue => e    
        flash[:error] = "There was an error submitting your File: #{e.message}. Please check it and submit it again."
      end
    end
    redirect_to :back
  # add rescue for local dev without redis running (for challenge participants)
  rescue Exception => e
    puts e.message
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
    @members = @deliverables.map{|d| d.username}
  end  

  # when signed in, if the status is NOT 'winner selected' or 'no winner selected' 
  # AND the user is not a challegne admin with a status of 'Scored - Awaiting Approval', redirect them.
  # if not signed in, the status must be 'winner selected' or 'no winner selected'
  def results
    if user_signed_in?
      unless ['winner selected','no winner selected'].include?(@challenge.status.downcase) || 
        (current_user.challenge_admin?(@challenge) && @challenge.status.downcase == 'scored - awaiting approval')
        redirect_to challenge_path, :alert => 'Results are not available at this time.' 
      end
    else
      unless ['winner selected','no winner selected'].include?(@challenge.status.downcase)
        redirect_to challenge_path, :alert => 'Results are not available at this time.' 
      end
    end
    @results_overview = current_challenge.results_overview
  end  

  def results_scorecard
    @participant = Participant.find_by_member(params[:id], params[:participant])
    @submissions = @participant.current_submissions(params[:id])
    scorecard_questions = Judging.participant_scorecard(@participant.id, params[:judge])
    @scorecard = JSON.parse(scorecard_questions.keys.first) 
    gon.scorecard = scorecard_questions.values.first
  rescue Exception => e
    redirect_to '/not_found'
  end

  def scorecard
    @scorecard_group = Challenge.scorecard_questions(params[:id])
  end  

  def appeals
    @participants = @challenge.participants
  end

  def survey
    if params[:survey]
      post_results = current_challenge.submit_post_survey(params[:survey])
      puts post_results.to_yaml
      flash[:notice] = "Thanks for completing the survey!" 
      redirect_to challenge_path     
    end
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
      delete_comments_cache
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
      @current_member_participant = Rails.cache.fetch("participant-#{current_user.username}-#{params[:id]}", :expires_in => 5.minute) do
        Participant.find_by_member(params[:id], current_user.username)
      end if user_signed_in?
    end

    def delete_particiapnt_cache
      Rails.cache.delete("participant-#{current_user.username}-#{params[:id]}")
    end

    def delete_comments_cache
      Rails.cache.delete("comments-#{params[:id]}")
    end    

    def challenge_must_be_open
      redirect_to challenge_path, :alert => 'This challenge is no longer open.' unless current_challenge.open? || current_user_participant.override_submission_upload
    end  

    def must_be_registered
      redirect_to challenge_path, :alert => 'You must be registered for this challenge before can submit.' if ['not registered','watching'].include?(@current_member_participant.status.downcase)
    end 

    def send_task_submission_notification
      # if they don't have a submission yet then they are uplaoding their first one
      if !@current_member_participant.has_submission
        notification = {membername: 'clyde', comments: 'A new submission has been uploaded for this task.'}
        results = @challenge.create_comment(notification)
        delete_comments_cache
      end
    end   

    def restrict_appeallate_member
      being_appealed = RestforceUtils.query_salesforce("select id, being_appealed__c 
        from challenge__c where challenge_id__c = '#{@challenge.challenge_id}'").first.being_appealed
      appellate_member = RestforceUtils.query_salesforce("select id, appellate_member__c 
        from member__c where name = '#{@current_user.username}'").first.appellate_member       
      redirect_to challenge_path, :alert => 'No access to requested page.' unless (being_appealed && appellate_member)
    end

    def redirect_advanced_search
      redirect_to challenges_path unless params[:advanced]
    end  

    def search_default_params
      @platforms = all_platforms
      @technologies = all_technologies
      @categories = all_categories
      @sort_by_options = [["End Date", "end_date"],["Challenge Title", "name"],["Prize Money", "total_prize_money desc"]]
      @communities = Community.names
      @communities.insert(0, 'Public') if !@communities.include?('Public')
      gon.adv_search_display = false
      gon.adv_search_status = 'open'
      gon.adv_search_order_by = 'asc'
      @selected_sort_by = ''
      @selected_community = ''
      @selected_platforms = []
      @selected_technologies = []
      @selected_categories = []
      @selected_platforms_all = true
      @selected_technologies_all = true
      @selected_categories_all = true
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
