class Challenge < ApiModel
  include Redis::ChallengeSearchable

  attr_accessor :id, :challenge_id, :challenge_type, :attributes,
    :prize_type, :total_prize_money, :top_prize,
    :start_date, :end_date, :review_date, :usage_details, :requirements, :post_reg_info,
    :name, :description, :status, :release_to_open_source, :additional_info,
    :categories, :is_open, :discussion_board, :registered_members, :challenge_prizes,
    :submission_details, :winner_announced, :community, :days_till_close,
    :platforms, :technologies, :submissions, :participating_members, :default_tos,
    :challenge_prizes, :challenge_participants, :registration_end_date, :account,

    # these are only available if you call /admin on the model
    # e.g. http://cs-api-sandbox.herokuapp.com/v1/challenges/2/admin
    :challenge_reviewers, :challenge_comment_notifiers, :assets

  has_many :comments
  has_many :participants
  has_many :submission_deliverables
  has_many :scorecards

  # Cleanup up the __r convention -- may want to delete this
  def initialize(params={})
    # there has GOT to be some better way to clean this up ...
    params['categories'] = params.delete('challenge_categories__r') if params['challenge_categories__r']
    params['challenge_participants'] = params.delete('challenge_participants__r') if params['challenge_participants__r']
    params['community'] = params.delete('community__r') if params['community__r']
    params['terms_of_service'] = params.delete('terms_of_service__r') if params['terms_of_service__r']
    params['challenge_comments'] = params.delete('challenge_comments__r') if params['challenge_comments__r']
    params['challenge_reviewers'] = params.delete('challenge_reviewers__r') if params['challenge_reviewers__r']
    params['challenge_comment_notifiers'] = params.delete('challenge_comment_notifiers__r') if params['challenge_comment_notifiers__r']
    params['challenge_prizes'] = params.delete('challenge_prizes__r') if params['challenge_prizes__r']
    params['assets'] = params.delete('assets__r') if params['assets__r']
    params['platforms'] = params.delete('challenge_platforms__r') if params['challenge_platforms__r']
    params['technologies'] = params.delete('challenge_technologies__r') if params['challenge_technologies__r']

    params['challenge_prizes'] = params['challenge_prizes'].records.map do |entry|
      prize = "$#{Integer(entry['prize'])}" rescue entry['prize'].to_s
      { place: entry['place'].to_i.ordinalize, prize: prize, points: entry['points'] || '', value: entry['value'] || '' }
    end if params['challenge_prizes']

    # if no prizes were set up yet....
    params['challenge_prizes'] = [] unless params['challenge_prizes']

    # params['assets'] = params['assets'].map do |entry|
    #   entry['filename']
    # end if params['assets']

    super(params)
  end

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/challenges"
  end

  def self.increment_page_views(id) 
    restforce_client.get "#{ENV['SFDC_APEXREST_URL']}/challenges/#{id}/pageview"
  end 

  def self.scorecard_questions(id)
    naked_get("challenges/#{id}/scorecard")
  end  

  # Used for resourceful routes (instead of id)
  def to_param
    challenge_id
  end

  def self.open    
    request(:get, '', {}).map {|challenge| Challenge.new challenge}
  end

  def self.per_page
    10
  end

  # options are
  #   technology, platform, category, order_by
  def self.all(options = {})
    options.each {|k,v| options.delete(k) if v.blank? } if options
    naked_get('challenges', options).map {|challenge| Challenge.new challenge}
  end  

  # def submission_deliverables
  #   self.class.raw_get_has_many([to_param, 'submissions']).map {|submission| Submission.new(submission)}
  # end

  # Return an object instead of a string
  def start_date
    Time.parse(@start_date) if @start_date
  end

  # Return an object instead of a string
  def end_date
    Time.parse(@end_date) if @end_date
  end

  def end_date_utc
    DateTime.parse(@end_date).getutc if @end_date
  end  

  def winner_announced
    Date.parse(@winner_announced) if @winner_announced
  end  

  def review_date
    Date.parse(@review_date) if @review_date
  end    

  def challenge_comments
    return [] if @challenge_comments.blank?
    @challenge_comments.records.map {|comment| Comment.new(comment)}
  end

  # TODO: DEPRECATED
  def categories
    return [] if @categories.blank?
    @categories.records.map {|c| c.display_name}
  end

  def category_names
    return [] if @categories.blank?
    @categories.records.map(&:display_name)
  end

  def platforms
    return [] if @platforms.blank?
    if @platforms.is_a? Array
      @platforms.map(&:name)   
    else 
      @platforms.records.map(&:name)  
    end 
  end

  def technologies
    return [] if @technologies.blank?
    if @technologies.is_a? Array
      @technologies.map(&:name)   
    else 
      @technologies.records.map(&:name)  
    end  
  end

  def assets
    return [] if @assets.blank?
    @assets.records.map(&:filename)
  end

  def uses_default_tos?
    raw_data.terms_of_service.default_tos
  end  

  def tos
    raw_data.terms_of_service.id
  end

  def community_name
    community.try(:name)
  end

  def open?
    if Time.now.utc < end_date_utc
      true
    else
      false
    end
  end

  def show_discussion_board_entry?
    open? && @discussion_board == 'Show'
  end

  def closed_for_registration?
    @registration_end_date.nil? ? false : Time.parse(@registration_end_date.getutc).past?
  end  

  def release_to_open_source?
    !!@release_to_open_source
  end

  def create_comment(attrs)
    attrs[:challenge_id] = challenge_id
    self.class.post [challenge_id, "comment"], {data: attrs}
  end

  def submission_of(user)
    Submission.find(challenge_id, user.username)
  end 

  def preview?
    @status.downcase == "planned"
  end

  def active?
    ['Created', 'Submission', 'Review', 'Review - Pending'].include?(status)
  end

  private

    def self.restforce_client
      client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
        :password       => ENV['SFDC_PUBLIC_PASSWORD'],
        :client_id      => ENV['SFDC_CLIENT_ID'],
        :client_secret  => ENV['SFDC_CLIENT_SECRET'],
        :host           => ENV['SFDC_HOST']
      client
    end 

end

