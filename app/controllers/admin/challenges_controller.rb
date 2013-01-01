class Admin::ChallengesController < ApplicationController
  # optionally, inherit from ::ProtectedController to gain any kind of protection
  # in a standard way; maybe username/password or refinery usertypes?

  def new
    @challenge = Admin::Challenge.new
  end

  def create
    #raise params.inspect
    params[:admin_challenge][:reviewers] = params[:admin_challenge][:reviewers].split(',')
    params[:admin_challenge][:commentNotifiers] = params[:admin_challenge][:commentNotifiers].split(',')
    params[:admin_challenge][:assets] = params[:admin_challenge][:assets].split(',')
    @challenge = Admin::Challenge.new(params[:admin_challenge])
    render json: @challenge.payload
  end

  def assets
    # TODO: fog is now used twice; should we extract this to a helper function?
    fog = Fog::Storage.new(
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['AWS_KEY'] || APP_CONFIG[:s3][:key],
      :aws_secret_access_key    => ENV['AWS_SECRET'] || APP_CONFIG[:s3][:secret],
    )
    storage = fog.directories.get(APP_CONFIG[:s3][:bucket])

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
    @asset = {url: file.public_url}
  end
end
