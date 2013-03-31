class Admin::ChallengesController < ApplicationController
  # optionally, inherit from ::ProtectedController to gain any kind of protection
  # in a standard way; maybe username/password or refinery usertypes?

  def index
    @challenges = ::Challenge.all.sort_by {|c| c.challenge_id.to_i }
  end

  def new
    @challenge = Admin::Challenge.new
    puts @challenge.challenge_id.nil?

    # defaulted to the current time so that the user can make changes if desired
    @challenge.start_date = Time.now.ctime

    @challenge_platforms = []
    @challenge_technologies = []

    @challenge_reviewers = []
    @challenge_commentNotifiers = []

    @prizes = []
  end

  def edit
    challenge = ::Challenge.find([params[:id], 'admin'].join('/'))
    @challenge = Admin::Challenge.new(challenge.raw_data)
        puts @challenge.challenge_id
    #=render :json => @challenge

    # clean up places -- '1st' to 1
    @challenge.prizes.each { |p| p.place = p.place[0..0] }

    @challenge_platforms = @challenge.platforms.records.map(&:name)
    @challenge_technologies = @challenge.technologies.records.map(&:name)

    @challenge_reviewers = []

    @challenge.reviewers.each do | reviewer |
      @challenge_reviewers.push(reviewer.member__r.name) 
    end

    @challenge_commentNotifiers = []

    @challenge.commentNotifiers .each do | commentNotifier |
      @challenge_commentNotifiers.push(commentNotifier.member__r.name) 
    end

    @prizes = @challenge.prizes || []

  end

  def create
    params[:admin_challenge][:reviewers] = params[:admin_challenge][:reviewers].split(',') if params[:admin_challenge][:reviewers]
    params[:admin_challenge][:commentNotifiers] = params[:admin_challenge][:commentNotifiers].split(',') if params[:admin_challenge][:commentNotifiers]
    params[:admin_challenge][:assets] = params[:admin_challenge][:assets].split(',') if params[:admin_challenge][:assets]
    
    params[:admin_challenge][:categories] = params[:admin_challenge][:categories].split(',') if params[:admin_challenge][:categories]
    params[:admin_challenge][:platforms] = params[:admin_challenge][:platforms].split(',') if params[:admin_challenge][:platforms]
    params[:admin_challenge][:technologies] = params[:admin_challenge][:technologies].split(',') if params[:admin_challenge][:technologies]

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

    # community judging ?

    # private community ?

    # cleanup the params hash
    1.upto(5) { |i| params[:admin_challenge].delete "start_date(#{i}i)" }

    @challenge = Admin::Challenge.new(params[:admin_challenge])

    if @challenge.challenge_id
      redirect_url = '/admin/challenges/' + @challenge.challenge_id + '/edit'
    else
      redirect_url = '/admin/challenges/new'
    end

    if @challenge.valid?

      # create or update challenge

      #redirect_to redirect_url, notice: 'Challenge saved'

      #ap @challenge.payload.as_json
      #render json: @challenge.payload
    else
      puts @challenge.errors.inspect
      #redirect_to redirect_url, notice: 'Validation failed'
    end
    results = @challenge.save
    puts results
    render :json => @challenge.payload
  end

  def assets
    # TODO: fog is now used twice; should we extract this to a helper function?
    fog = Fog::Storage.new(
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['AWS_KEY'],
      :aws_secret_access_key    => ENV['AWS_SECRET'],
    )
    storage = fog.directories.get(ENV['AWS_BUCKET'])

    # create the folder for this challenge
    # QUESTION: How to name the challenge folder? Since this is a new challenge,
    # we still do not have a challenge id. There are a few approaches we can take:
    # - look up the challenges api and use the last challenge id + 1; however
    #   this method is prone to race conditions (when two challenge creators try
    #   to create a challenge at the same time). It becomes too complicated to
    #   create mutexes for this scenario
    # - generate a unique hash. This gives us the benefit of a very low probabilty
    #   of a folder clash happening; however the bucket is not human readable
    #   anymore (you can't look at a folder and immediately tell that it belongs
    #   to a particular challenge)
    # - use a two-step process where a challenge HAS to be created first (and thus
    #   a challenge id is already assigned), then create a folder and upload to
    #   it. This I think is the best approach. I am leaving the uploader at the
    #   first step for now as a proof of concept; once the API endpoint for saving
    #   (and retrieving the challenge id assigned) is up, we can move this to
    #   the second step.

    # for now, let's just use the form's authenticity token as the folder name
    folder = params[:authenticity_token]

    # If we're hosting this on heroku, then we might run into timeout problems.
    # We should look into uploading to S3 directly, or spinning off a small server
    # to handle file uploads. This server can also be used for the submission
    # deliverables (e.g. large videos or files).
    file = storage.files.create(
      key: [folder, params[:name]].join('/'),
      body: params[:file].read,
      :public => true
    )

    # create the file in this folder
    @asset = {url: file.public_url, filename: params[:name]}
  end

end
