class Admin::Challenge
  include ActiveModel::Model

  STATUSES = [['Draft', 'Draft'] ,['Open for Submissions', 'Open for Submissions'] ,['Hidden', 'Hidden']]

  # Overrides the attr_accesssor class method so we are able to capture and
  # then save the defined fields as column_names
  def self.attr_accessor(*vars)
    @column_names ||= []
    @column_names.concat( vars )
    super
  end

  # Returns the previously defined attr_accessor fields
  def self.column_names
    @column_names
  end

  cattr_accessor :access_token

  attr_accessor :winner_announced, :review_date, :terms_of_service, :scorecard_type, :submission_details,
                :status, :start_date, :requirements, :name, :status, :end_date, :description, :community_judging,
                :reviewers, :platforms, :technologies, :prizes, :commentNotifiers, :community, :registered_members,
                :assets, :challenge_type, :terms_of_service, :comments, :challenge_id, :submissions, 
                :account, :contact, :auto_announce_winners,

                # these are fields from the challenge api that need to be there so we can
                # just "eat" the json and avoid the model from complaining that these
                # fields don't exist

                # IDEA FOR REFACTORING:
                # We should instead have a slave ::Challenge object to consume the original
                # challenge params and extract out whatever data we need. The way this is
                # being implemented right now smells of feature envy.
                :attributes, :total_prize_money, :submissions, :usage_details, :is_open,
                :release_to_open_source, :post_reg_info, :prize_type, :discussion_board,
                :registered_members, :challenge_comments, :additional_info,
                :participating_members, :challenge_prizes,
                :top_prize, :id, :participants

  # Add validators as you like :)
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :review_date, presence: true
  validates :winner_announced, presence: true
  validates :description, presence: true
  validates :requirements, presence: true
  validates :account, presence: true

  validate  do
    if start_date && end_date && winner_announced && review_date
      errors.add(:end_date, 'must be after start date') unless end_date > start_date
      errors.add(:winner_announced, 'must be after end date') unless winner_announced >= end_date.to_date
      errors.add(:review_date, 'must be after end date') unless review_date >= end_date.to_date
    end
  end

  def initialize(params={})
    # the api names some fields as challenge_xxx where as the payload needs to be xxx
    params['reviewers'] = params.delete('challenge_reviewers') if params.include? 'challenge_reviewers'
    params['commentNotifiers'] = params.delete('challenge_comment_notifiers') if params.include? 'challenge_comment_notifiers'
    params['prizes'] = params.delete('challenge_prizes') if params.include? 'challenge_prizes'

    # just want the contact name form the contact and not their id
    if params.include? 'contact__r'
      params['contact'] = params['contact__r']['name'] unless !params['contact__r']
      params.delete('contact__r')
    end
    super(params)
  end

  def challenge_id
    @challenge_id unless @challenge_id.blank? || nil
  end

  # Return an object instead of a string
  def start_date
    (Time.parse(@start_date) if @start_date) || Date.today
  end

  # Return an object instead of a string
  def end_date
    (Time.parse(@end_date) if @end_date) || Date.today + 7.days
  end

  # Return an object instead of a string
  def winner_announced
    (Date.parse(@winner_announced) if @winner_announced) || Date.today + 12.days
  end

  def review_date
    (Time.parse(@review_date) if @review_date) || Date.today + 9.days
  end
  
  def statuses
    Admin::Challenge::STATUSES
  end

  def scorecards
    scorecards = RestforceUtils.query_salesforce('select Name from QwikScore__c where active__c = true order by name')
    scorecards.map {|s| s.name}
  end  

  def terms_of_services
    scorecards = RestforceUtils.query_salesforce('select Name from Terms_of_Service__c order by name')
    scorecards.map {|s| s.name}
  end  

  def categories
    challenge_types = RestforceUtils.client.picklist_values('Challenge__c', 'Challenge_Type__c')
    challenge_types.map {|s| s.value}
  end    

  def communities
    # make sure we are using the correct access token
    ApiModel.access_token = access_token
    Community.all.map {|c| c.name}
  end      

  def platforms
    @platforms || []
  end

  def technologies
    @technologies || []
  end 

  def assets
    @assets || []
  end   

  def reviewers
    @reviewers || []
  end

  def commentNotifiers
    @commentNotifiers || []
  end

  def prizes
    @prizes || []
  end

  def save
    puts payload
    if challenge_id
      options = {
        :query => {data: payload},
        :headers => api_request_headers
      }
      Hashie::Mash.new HTTParty::put("#{ENV['CS_API_URL']}/challenges/#{challenge_id}", options)['response']    
    else
      options = {
        :body => {data: payload}.to_json,
        :headers => api_request_headers
      }
      Hashie::Mash.new HTTParty::post("#{ENV['CS_API_URL']}/challenges", options)['response']
    end
  end

  def api_request_headers
    {
      'oauth_token' => access_token,
      'Authorization' => 'Token token="'+ENV['CS_API_KEY']+'"',
      'Content-Type' => 'application/json'
    }
  end  

  # formats the object to conform to the api format
  # maybe we should use RABL for this one instead?
  def payload
    # Get the original challenge to figure out the stuff to be deleted.
    # We are re-requesting the original challenge instead of tracking which
    # entries are to be deleted client-side to minimize race conditions. Race
    # conditions aren't totally eliminated, but the window is largely smaller
    # in this case. Plus the logic is much simpler too :)

    result = {
      challenge: {
        detail: {
          account: account,
          contact: contact,
          winner_announced: winner_announced,
          terms_of_service: terms_of_service,
          scorecard_type: scorecard_type,
          submission_details: submission_details,
          status: status,
          start_date: start_date.to_time.iso8601,
          requirements: requirements,
          name: name,
          end_date: end_date.to_time.iso8601,
          description: description,
          comments: comments,
          challenge_type: challenge_type,
          community_judging: community_judging,
          auto_announce_winners: auto_announce_winners,
          community: community,
          community_judging: community_judging,
          auto_announce_winners: auto_announce_winners,
          challenge_id: challenge_id
        },
        reviewers: reviewers.map {|name| {name: name}},
        platforms: platforms.map {|name| {name: name}},
        technologies: technologies.map {|name| {name: name}},
        prizes: prizes,
        commentNotifiers: commentNotifiers.map {|name| {name: name}},
        assets: assets.map {|filename| {filename: filename}},
      }
    }
    result
  end

end