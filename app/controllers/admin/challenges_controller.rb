class Admin::ChallengesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_challenge, :only => [:edit]
  before_filter :restrict_by_account_access
  before_filter :restrict_edit_by_account, :only => [:edit]

  def index
    @administering_account = current_user.accountid
    @administering_account = params[:account] if params[:account]
    @challenges = RestforceUtils.get_apex_rest("/admin/challenges?account=#{@administering_account}", 
      current_user.access_token, nil, 'v1')
    @challenges.map {|challenge| Admin::Challenge.new challenge}
    @sponsors = all_sponsors if current_user.sys_admin?

    @logo = Rails.cache.fetch("account-logo-#{@administering_account}", :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do
      RestforceUtils.query_salesforce("select logo__c from account where id = '#{@administering_account}'", nil, :admin).first.logo 
    end

  end

  def create
    render :json =>  { success: false, error: "Creating challenges has been disabled. Please use CMC to create challenges." } 
  end

  def edit

    # move the existing assets to a new array
    @current_assets = @challenge.assets || []
    # this array will only contain new assets being uploaded  
    @challenge.assets = []

    # clean up places -- '1st' to 1
    @challenge.prizes.each { |p| p.place = p.place.to_s[0..0] }

    @challenge_platforms = @challenge.platforms.map(&:name).join(',') unless @challenge.platforms.empty?
    @challenge_technologies = @challenge.technologies.map(&:name) .join(',') unless @challenge.technologies.empty? 

    # set the time picklistt for the end time based upon the user's timezone
    @challenge.end_time = @challenge.end_date.hour

    # find out if there are madison requirements for this challenge
    @madison_requirements = Requirement.where("challenge_id = ?", params[:id]).count

    @can_edit_challenge_requirements = false
    @can_edit_challenge_requirements = true if @challenge.status.downcase.eql?('draft')

    @all_platforms = all_platforms
    @all_technologies = all_technologies

    @steps = [
      Hashie::Mash.new(:shortname => "step1", :name => "Basic Info"),
      Hashie::Mash.new(:shortname => "step2", :name => "Details"),
      Hashie::Mash.new(:shortname => "step3", :name => "Technologies"),
      Hashie::Mash.new(:shortname => "step4", :name => "Prizes"),
      Hashie::Mash.new(:shortname => "assets", :name => "Assets"),      
      Hashie::Mash.new(:shortname => "step5", :name => "Optional"),
      Hashie::Mash.new(:shortname => "review-update", :name => "Review & Save")
    ]

    if current_user.sys_admin?
      @sponsors = all_sponsors
      @terms_of_service = all_terms_of_service
      # if sys admin, add the admin tab
      @steps.insert(-2, Hashie::Mash.new(:shortname => "admin", :name => "Admin")) 
    end

  end

  def update

    # scrub out this crap when nothing submitted in ckeditor -- <p>&Acirc;&#32;</p>\r\n (see http://dev.ckeditor.com/ticket/9732)
    params[:admin_challenge][:description] = nil if params[:admin_challenge][:description].include?('&Acirc;&#32;')
    params[:admin_challenge][:requirements] = nil if params[:admin_challenge][:requirements].include?('&Acirc;&#32;')
    params[:admin_challenge][:submission_details] = nil if params[:admin_challenge][:submission_details].include?('&Acirc;&#32;')

    params[:admin_challenge][:assets] = params[:admin_challenge][:assets].split(',') if params[:admin_challenge][:assets]
    params[:admin_challenge][:platforms] = params[:admin_challenge][:platforms].split(',') if params[:admin_challenge][:platforms]
    params[:admin_challenge][:technologies] = params[:admin_challenge][:technologies].split(',') if params[:admin_challenge][:technologies]
    # only use the first contact entered
    params[:admin_challenge][:contact] = params[:admin_challenge][:contact].split(',').first if params[:admin_challenge][:contact]

    # remove blank files names that are coming across for some reason
    params[:admin_challenge][:assets].reject! { |c| c.empty? } if params[:admin_challenge][:assets]

    end_time = params[:admin_challenge][:end_time]

    s_date = params[:admin_challenge][:start_date]
    # replace the time and timezone so it's parsed correctly
    params[:admin_challenge][:start_date_for_sfdc] = s_date.gsub('00:00:00', "#{end_time}:00:00").gsub('(UTC)', "(#{current_user.time_zone})")

    e_date = params[:admin_challenge][:end_date]
    # replace the time and timezone so it's parsed correctly
    params[:admin_challenge][:end_date_for_sfdc] = e_date.gsub('23:59:59', "#{end_time}:00:00").gsub('(UTC)', "(#{current_user.time_zone})")    

    # review_date and winner_announced
    r = Time.parse(params[:admin_challenge][:end_date]) + 2.days
    w = Time.parse(params[:admin_challenge][:end_date]) + 7.days
    # add the time element
    min = 0
    t = Time.mktime(1 ,1 ,1 ,end_time.to_i, min)

    params[:admin_challenge][:review_date] = Time.mktime(r.year, r.month, r.day, t.hour, t.min).ctime
    params[:admin_challenge][:winner_announced] = Time.mktime(w.year, w.month, w.day, t.hour, t.min).ctime   

    # cleanup the params hash
    1.upto(5) { |i| params[:admin_challenge].delete "start_date(#{i}i)" }

    # clean up the prizes
    params[:admin_challenge][:prizes] = params[:admin_challenge][:prizes] || []
    params[:admin_challenge][:prizes].delete_if {|p| p['prize'] == '' }
    # make sure the prizes have values and points
    params[:admin_challenge][:prizes].each do |p|
      p['prize'] = "$#{p['prize']}" unless p['prize'].include?('$')
      unless p.has_key?('points')
        p.merge!({:points => p['prize'].scan(/\d*/).second, :value => p['prize'].scan(/\d*/).second})
      end
    end

    @challenge = Admin::Challenge.new(params[:admin_challenge])
    # inject the user's timezone for proper sfdc conversion
    @challenge.timezone = current_user.time_zone

    # set the access token for the calls
    @challenge.access_token = current_user.access_token
    redirect_url = '/admin/challenges/' + @challenge.challenge_id + '/edit'

    if @challenge.valid?
      # create or update challenge
      results = @challenge.save
      if results.success
        redirect_to '/admin/challenges', notice: 'Challenge saved!'
      else
        redirect_to redirect_url, alert: results.errors.first.errorMessage
      end
    else
      @challenge.errors.full_messages.each {|msg| flash[:alert] = msg }
      redirect_to redirect_url
    end

  end

  def check_for_appirio_task
    if params[:task]

      cmc_client = Restforce.new :username => ENV['CMC_USERNAME'],
        :password         => ENV['CMC_PASSWORD'],
        :client_id          => ENV['CMC_CLIENT_ID'],
        :client_secret    => ENV['CMC_CLIENT_SECRET'],
        :host                 => ENV['CMC_HOST']

      cmc_client.authenticate!
      task = cmc_client.query("select id, name, task_name__c, description__c from 
        cmc_task__c where id = '#{params[:task]}'")

      unless task.empty?
        @challenge.name = task.first.Task_Name__c
        @challenge.description = task.first.Description__c unless task.first.Description__c.nil? || task.first.Description__c == '<br>'
        @challenge.cmc_task = params[:task]
        # @challenge.scorecard_type = 'Sandbox Scorecard'
        # @challenge.terms_of_service = 'Standard Terms & Conditions'
      end

    end
  end  

  # called via ajax
  def delete_asset
    results = RestforceUtils.destroy_in_salesforce('Asset__c', params[:asset_id], :admin)
    render :text => results[:success]
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

  private

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

    def load_challenge
      @challenge = Admin::Challenge.new(Admin::Challenge.find(params[:id], current_user.access_token).first)
      # inject the user's timezone for proper sfdc conversion
      @challenge.timezone = current_user.time_zone
    end  

    # all accounts marked as a 'sponsor'
    def all_sponsors
      Rails.cache.fetch('all-sponsors', :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do 
        RestforceUtils.query_salesforce("select id, name from account where 
          type = 'sponsor' order by name", nil, :admin)
      end
    end     

    def all_terms_of_service
      Rails.cache.fetch('all-terms-of-service', :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do 
        RestforceUtils.query_salesforce("select id, name from terms_of_service__c 
          order by name", nil, :admin)
      end
    end     

    # make sure users cannot edit challenges from another account
    def restrict_edit_by_account
      redirect_to challenges_path, :alert => 'You do not have access to this page.' unless @challenge.account == current_user.accountid || current_user.sys_admin?
    end    

    def restrict_by_account_access
      account = RestforceUtils.query_salesforce("select can_admin_challenges__c from account where id = '#{current_user.accountid}'", nil, :admin).first 
      redirect_to challenges_path, :alert => 'You do not have access to this page.' unless account.try(:can_admin_challenges)
    end  

end
