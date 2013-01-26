class Challenge < ApiModel
  include Redis::ChallengeSearchable

  attr_accessor :id, :challenge_id, :challenge_type, :attributes,
    :prize_type, :total_prize_money, :top_prize,
    :start_date, :end_date, :usage_details, :requirements, :post_reg_info,
    :name, :description, :status, :release_to_open_source, :additional_info,
    :categories, :is_open, :discussion_board, :registered_members,
    :submission_details, :winner_announced, :community, :days_till_close,

    # these are only available if you call /admin on the model
    # e.g. http://cs-api-sandbox.herokuapp.com/v1/challenges/2/admin
    :challenge_reviewers, :challenge_comment_notifiers, :assets

  has_many :comments

  # Note that we're not using the participants data in the json because it
  # lacks many attributes. We simply just do another api call.
  has_many :participants

  # Cleanup up the __r convention -- may want to delete this
  def initialize(params={})
    # there has GOT to be some better way to clean this up ...
    params['categories'] = params.delete('challenge_categories__r') if params['challenge_categories__r']
    params['participants'] = params.delete('challenge_participants__r') if params['challenge_participants__r']
    params['community'] = params.delete('community__r') if params['community__r']
    params['terms_of_service'] = params.delete('terms_of_service__r') if params['terms_of_service__r']
    params['challenge_comments'] = params.delete('challenge_comments__r') if params['challenge_comments__r']
    params['challenge_reviewers'] = params.delete('challenge_reviewers__r') if params['challenge_reviewers__r']
    params['challenge_comment_notifiers'] = params.delete('challenge_comment_notifiers__r') if params['challenge_comment_notifiers__r']
    params['challenge_prizes'] = params.delete('challenge_prizes__r') if params['challenge_prizes__r']
    params['assets'] = params.delete('assets__r') if params['assets__r']

    # these fields need extra cleaning as they should only output arrays of strings
    # they also have an awful lot of duplication that can benefit with a bit of refactoring
    params['challenge_reviewers'] = params['challenge_reviewers'].map do |entry|
      entry['member__r']['name']
    end if params['challenge_reviewers']

    params['challenge_comment_notifiers'] = params['challenge_comment_notifiers'].map do |entry|
      entry['member__r']['name']
    end if params['challenge_comment_notifiers']

    params['challenge_prizes'] = params['challenge_prizes'].records.map do |entry|
      { place: entry['place'].to_s, prize: entry['prize'].to_s, points: entry['points'] || '', value: entry['value'] || '' }
    end if params['challenge_prizes']

    # params['assets'] = params['assets'].map do |entry|
    #   entry['filename']
    # end if params['assets']

    super(params)
  end

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/challenges"
  end

  # Used for resourceful routes (instead of id)
  def to_param
    challenge_id
  end

  # Returns all the closed challenges
  def self.closed
    request(:get, 'closed', {}).map {|challenge| Challenge.new challenge}
  end

  def self.open
    request(:get, '', {}).map {|challenge| Challenge.new challenge}
  end

  def self.all
    closed + open
  end

  # Returns all the recent challenges
  def self.recent
    request(:get, 'recent', {}).map {|challenge| Challenge.new challenge}
  end

  # Return an object instead of a string
  def start_date
    Date.parse(@start_date) if @start_date
  end

  # Return an object instead of a string
  def end_date
    Date.parse(@end_date) if @end_date
  end

  # TODO: blow up the categories into something useful
  def categories
    @categories.records.map {|c| c.display_name}
  end

  def category_names
    categories.records.map(&:display_name)
  end

  def assets
    assets.records.map(&:filename)
  end

  def community_name
    community.try(:name)
  end

  def open?
    @is_open == "true"
  end

  def release_to_open_source?
    !!@release_to_open_source
  end

  def winner_announced
    Date.parse(@winner_announced) if @winner_announced
  end

  # has_one :status
  # TODO (this requires authentication)
  # edit Nov 22: apparently not? O_O
  # def status
  #   'nil'
  # end

  def submission_of(user)
    Submission.find(challenge_id, user.username)
  end
end

