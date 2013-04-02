class Admin::ChallengesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @challenges = RestforceUtils.query_salesforce("select name, challenge_id__c, status__c, 
      challenge_type__c, registered_members__c, submissions__c
      from challenge__c where status__c IN ('Planned','Created','Hidden') order by end_date__c desc", current_user.access_token)
    @challenges.map {|challenge| Admin::Challenge.new challenge}
  end

  def new
    @challenge = Admin::Challenge.new
    # set the access token for the calls
    @challenge.access_token = current_user.access_token
    # defaulted to the current time so that the user can make changes if desired
    @challenge.start_date = Time.now.ctime
    @challenge_platforms = []
    @challenge_technologies = []
    @challenge_reviewers = []
    @challenge_commentNotifiers = []
    # default in a first place prize
    @prizes = [Hashie::Mash.new(:place => 1, :points => 100, :prize => '$100', :value => 100)]
  end

  def edit
    challenge = ::Challenge.find([params[:id], 'admin'].join('/'))
    @challenge = Admin::Challenge.new(challenge.raw_data)
    # set the access token for the calls
    @challenge.access_token = current_user.access_token    

    @challenge_reviewers = []
    @challenge_commentNotifiers = []
    @prizes = @challenge.prizes || []    

    # clean up places -- '1st' to 1
    @challenge.prizes.each { |p| p.place = p.place[0..0] }

    @challenge_platforms = @challenge.platforms.records.map(&:name)
    @challenge_technologies = @challenge.technologies.records.map(&:name)

    @challenge.reviewers.each do | reviewer |
      @challenge_reviewers.push(reviewer.member__r.name) 
    end

    @challenge.commentNotifiers .each do | commentNotifier |
      @challenge_commentNotifiers.push(commentNotifier.member__r.name) 
    end

    @challenge.commentNotifiers .each do | commentNotifier |
      @challenge_commentNotifiers.push(commentNotifier.member__r.name) 
    end    

  end

  def create
    # scrub out this crap when nothing submitted in ckeditor -- <p>&Acirc;&#32;</p>\r\n (see http://dev.ckeditor.com/ticket/9732)
    params[:admin_challenge][:description] = nil if params[:admin_challenge][:description].include?('&Acirc;&#32;')
    params[:admin_challenge][:requirements] = nil if params[:admin_challenge][:requirements].include?('&Acirc;&#32;')
    params[:admin_challenge][:submission_details] = nil if params[:admin_challenge][:submission_details].include?('&Acirc;&#32;')

    params[:admin_challenge][:reviewers] = params[:admin_challenge][:reviewers].split(',') if params[:admin_challenge][:reviewers]
    params[:admin_challenge][:commentNotifiers] = params[:admin_challenge][:commentNotifiers].split(',') if params[:admin_challenge][:commentNotifiers]
    params[:admin_challenge][:assets] = params[:admin_challenge][:assets].split(',') if params[:admin_challenge][:assets]
    params[:admin_challenge][:platforms] = params[:admin_challenge][:platforms].split(',') if params[:admin_challenge][:platforms]
    params[:admin_challenge][:technologies] = params[:admin_challenge][:technologies].split(',') if params[:admin_challenge][:technologies]

    # remove blank files names that are coming across for some reason
    params[:admin_challenge][:assets].reject! { |c| c.empty? } if params[:admin_challenge][:assets]

    # add the time element
    hour = params[:admin_challenge]['start_date(4i)']
    min = params[:admin_challenge]['start_date(5i)']
    t = Time.mktime(1 ,1 ,1 ,hour, min)
    s = Time.parse(params[:admin_challenge][:start_date])
    e = Time.parse(params[:admin_challenge][:end_date])
    params[:admin_challenge][:start_date] = Time.mktime(s.year, s.month, s.day, t.hour, t.min).ctime
    params[:admin_challenge][:end_date] = Time.mktime(e.year, e.month, e.day, t.hour, t.min).ctime

    # review_date and winner_announced
    r = Time.parse(params[:admin_challenge][:review_date])
    w = Time.parse(params[:admin_challenge][:winner_announced])

    params[:admin_challenge][:review_date] = Time.mktime(r.year, r.month, r.day, t.hour, t.min).ctime
    params[:admin_challenge][:winner_announced] = Time.mktime(w.year, w.month, w.day, t.hour, t.min).ctime    

    # cleanup the params hash
    1.upto(5) { |i| params[:admin_challenge].delete "start_date(#{i}i)" }

    @challenge = Admin::Challenge.new(params[:admin_challenge])
    # set the access token for the calls
    @challenge.access_token = current_user.access_token

    if @challenge.challenge_id
      redirect_url = '/admin/challenges/' + @challenge.challenge_id + '/edit'
    else
      redirect_url = '/admin/challenges/new'
    end

    if @challenge.valid?
      # create or update challenge
      results = @challenge.save
      puts results.to_yaml

      if results.success
        #redirect_to redirect_url, notice: 'Challenge saved!'
      else
        #redirect_to redirect_url, alert: results.errors.first.errorMessage
      end

    else
      @challenge.errors.full_messages.each {|msg| flash[:alert] = msg }
      #redirect_to redirect_url
    end

    render :json => @challenge

  end

  def assets
    
    # TODO: fog is now used twice; should we extract this to a helper function?
    fog = Fog::Storage.new(
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['AWS_KEY'],
      :aws_secret_access_key    => ENV['AWS_SECRET'],
    )
    storage = fog.directories.get(ENV['AWS_BUCKET'])

    file = storage.files.create(
      key: ['challenges', params[:challenge_id], params[:name]].join('/'),
      body: params[:file].read,
      :public => true
    )

    # create the file in this folder
    @asset = {url: file.public_url, filename: params[:name]}

  end

end
