class Comment < ApiModel
  attr_accessor :id, :comment, :createddate, :member, :replies, :reply_to, :from_challenge_admin

  def self.api_endpoint
    "challenges"
  end   

  def self.has_many_api_endpoint
    api_endpoint
  end    

  # Cleanup up the __r convention
  def initialize(params={})
    params['member'] = params.delete('member__r') if params['member__r']
    params['replies'] = params.delete('challenge_comments__r') if params['challenge_comments__r']

    super(params)
  end

  def createddate
    Time.parse(@createddate) if @createddate
  end

  def replies
    return [] if @replies.blank?
    @replies.records.map {|c| Comment.new(c)}
  end

  def reply?
    @reply_to.present?
  end
end
