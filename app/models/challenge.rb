class Challenge < ApiModel
  attr_accessor :id, :challenge_id, :challenge_type, :attributes,
    :prize_type, :total_prize_money, :top_prize,
    :start_date, :end_date, :usage_details, :requirements, :post_reg_info,
    :name, :description, :status, :release_to_open_source, :additional_info,
    :categories, :is_open, :discussion_board, :registered_members,
    :submission_details, :winner_announced

  has_many :comments

  # Note that we're not using the participants data in the json because it
  # lacks many attributes. We simply just do another api call.
  has_many :participants

  # Cleanup up the __r convention
  def initialize(params={})
    params['categories'] = params.delete('challenge_categories__r')
    params['participants'] = params.delete('challenge_participants__r')
    super(params)
  end

  def self.api_endpoint
    APP_CONFIG[:cs_api][:challenges]
  end

  # Used for resourceful routes (instead of id)
  def to_param
    challenge_id
  end

  # Returns all the closed challenges
  def self.closed
    raw_get('closed').map {|challenge| Challenge.new challenge}
  end

  # Returns all the recent challenges
  def self.recent
    raw_get('recent').map {|challenge| Challenge.new challenge}
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
    @categories || 'nil'
  end

  def open?
    !!@is_open
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

