class Challenge < ApiModel
  include Redis::ChallengeSearchable

  attr_accessor :id, :challenge_id, :challenge_type, :attributes,
    :prize_type, :total_prize_money, :top_prize,
    :start_date, :end_date, :review_date, :usage_details, :requirements, :post_reg_info,
    :name, :description, :status, :release_to_open_source, :additional_info,
    :categories, :platforms, :technologies, 
    :is_open, :discussion_board, :registered_members, :challenge_prizes,
    :submission_details, :winner_announced, :community, :days_till_close,
    :submissions, :participating_members, :default_tos,
    :challenge_prizes, :challenge_participants, :registration_end_date, :account,
    :blogged, :auto_blog_url, :license_type__r, :require_registration, :docusign_document,

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
    params['platforms'] = params.delete('challenge_platforms__r') if params['challenge_platforms__r']
    params['technologies'] = params.delete('challenge_technologies__r') if params['challenge_technologies__r']

    params['challenge_participants'] = params.delete('challenge_participants__r') if params['challenge_participants__r']
    params['community'] = params.delete('community__r') if params['community__r']
    params['terms_of_service'] = params.delete('terms_of_service__r') if params['terms_of_service__r']
    params['challenge_comments'] = params.delete('challenge_comments__r') if params['challenge_comments__r']
    params['challenge_reviewers'] = params.delete('challenge_reviewers__r') if params['challenge_reviewers__r']
    params['challenge_comment_notifiers'] = params.delete('challenge_comment_notifiers__r') if params['challenge_comment_notifiers__r']
    params['challenge_prizes'] = params.delete('challenge_prizes__r') if params['challenge_prizes__r']
    params['assets'] = params.delete('assets__r') if params['assets__r']

    begin
      params['challenge_prizes'] = params['challenge_prizes'].records.map do |entry|
        prize = "$#{Integer(entry['prize'])}" rescue entry['prize'].to_s
        { place: entry['place'].to_i.ordinalize, prize: prize, points: entry['points'] || '', value: entry['value'] || '' }
      end if params['challenge_prizes']
    rescue
    end

    # if no prizes were set up yet or we couldn't parse the prizes (redis!) ....
    params['challenge_prizes'] = [] unless params['challenge_prizes']

    super(params)
  end

  # for challenge, cache it for 5 minutes
  def self.find(entity, current_user)
    if current_user
      puts "[CHALLENGE][CACHE] ======== calling find challenge"
      Rails.cache.fetch("#{self.api_endpoint}/#{entity}-#{current_user.username}", :expires_in => ENV['MEMCACHE_CHALLENGE_EXPIRY'].to_i.minute) do
        puts "[CHALLENGE][CACHE] ======== making call to #{self.api_endpoint}/#{entity}-#{current_user.username}"
        super entity
      end
    else
      super entity
    end
  end

  def self.api_endpoint
    "challenges"
  end

  def self.has_many_api_endpoint
    api_endpoint
  end    

  def self.increment_page_views(id) 
    RestforceUtils.get_apex_rest "/challenges/#{id}/pageview"
  end 

  def self.scorecard_questions(id)
    http_get("challenges/#{id}/scorecard")
  end  

  # Used for resourceful routes (instead of id)
  def to_param
    challenge_id
  end

  def self.search(keyword)
    http_get("challenges/search?keyword=#{keyword}")
  end          

  def self.advanced_search(options)
    
    params = Hashie::Mash.new()    

    if options[:platforms]
      if options[:platforms].include?('all platforms')
        params.p = 'all'
      else
        params.p = options[:platforms].join(",")
      end
    else
      params.p = 'none'
    end

    if options[:technologies]
      if options[:technologies].include?('all technologies')
        params.t = 'all'
      else
        params.t = options[:technologies].join(",")
      end
    else
      params.t = 'none'
    end

    if options[:categories]
      if options[:categories].include?('all categories')
        params.c = 'all'
      else
        params.c = options[:categories].join(",")
      end
    else
      params.c = 'none'
    end        
  
    params.p_min = options[:participants][:min]
    params.p_max = options[:participants][:max]
    params.m_min = options[:prize_money][:min]
    params.m_max = options[:prize_money][:max]
    params.state = options[:state]
    params.q = options[:query]
    params.sort_by = options[:sort_by]
    params.sort_order = options[:order]

    # fix this temp issue with field name -- need to change ui
    if options[:sort_by] == 'end_date'
      params.sort_by = "end_date__c" 
    elsif options[:sort_by] == 'total_prize_money desc'
      params.sort_by = 'total_prize_money__c'
    end

    http_get("challenges/advsearch?#{params.to_param}").map {|challenge| Challenge.new challenge}
  end

  def self.open    
    http_get('challenges').map {|challenge| Challenge.new challenge}
  end

  def self.recent(filters)
    http_get("challenges/recent", {:limit => 200}.merge!(filters)).map {|challenge| Challenge.new challenge}
  end

  def self.per_page
    10
  end

  # options are
  #   technology, platform, category, order_by
  def self.all(options = {})
    options.each {|k,v| options.delete(k) if v.blank? } if options
    http_get('challenges', options).map {|challenge| Challenge.new challenge}
  end  

  def self.closed(options = {})
    options.each {|k,v| options.delete(k) if v.blank? } if options
    http_get('challenges/closed', options).map {|challenge| Challenge.new challenge}
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

  def results_overview
    RestforceUtils.query_salesforce("select results_overview__c from challenge__c 
      where challenge_id__c = '#{@challenge_id}'").first.results_overview
  rescue Exception => e
    # simply return nil
  end

  def challenge_comments
    return [] if @challenge_comments.blank?
    @challenge_comments.records.map {|comment| Comment.new(comment)}
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

  def community_id
    community.try(:community_id)
  end  

  def open?
    return true if is_open.eql?('true')
    return false if is_open.eql?('false')
  end

  def show_discussion_board_entry?
    open? && @discussion_board == 'Show'
  end

  def closed_for_registration?
    @registration_end_date.nil? ? false : Time.parse(@registration_end_date).getutc.past?
  end  

  def release_to_open_source?
    !!@release_to_open_source
  end

  def create_comment(attrs)
    attrs[:challenge_id] = challenge_id
    self.class.http_post "challenges/#{challenge_id}/comment", {data: attrs}
  end

  def submit_post_survey(params)
    body = {
      :data => {
          :challenge => self.id,
          :compete_again => params[:compete_again],
          :prize_money => params[:prize_money],
          :requirements => params[:requirements],
          :timeframe => params[:timeframe],
          :why_no_submission => params[:why_no_submission],
          :improvements => params[:improvements]
      }
    }
    self.class.http_post("challenges/#{self.challenge_id}/survey", body)    
  end  

  def submission_of(user)
    Submission.find(challenge_id, user.username)
  end 

  def preview?
    @status.downcase == "draft"
  end

  def active?
    ['Open for Submissions', 'Review', 'Scored - Awaiting Approval'].include?(status)
  end

  def open_for_submissions?
    ['Open for Submissions'].include?(status)
  end  

  # member must be registered in order to view restricted challenge
  def show_assets?(participant, user)
    show_restricted_info(participant, user)
  end

  # member must be registered in order to view restricted challenge
  def show_discussion_board?(participant, user)
    show_restricted_info(participant, user)
  end    

  private

    def show_restricted_info(participant, user)
      # if a challenge admin always return true!
      return true if user && user.challenge_admin?(self)
      if @require_registration
        return false if participant.nil?
        if ['not registered', 'watching'].include?(participant.status.downcase)
          return false
        else
          return true
        end
      else
        true
      end
    end

end