class Comment < ApiModel
  attr_accessor :id, :attributes,
  	:comment, :createddate, :member, :replies, :reply_to

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/challenges"
  end

  # Cleanup up the __r convention
  def initialize(params={})
    params['member'] = params.delete('member__r')
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

# http://cs-api-sandbox.herokuapp.com/v1/challenges/2/comments

# {
#     "attributes": {
#         "type": "Challenge_Comment__c",
#         "url": "/services/data/v22.0/sobjects/Challenge_Comment__c/a09J0000003TRecIAG"
#     },
#     "member__r": {
#         "attributes": {
#             "type": "Member__c",
#             "url": "/services/data/v22.0/sobjects/Member__c/a0IJ0000000fSAGMA2"
#         },
#         "name": "test2localhost",
#         "id": "a0IJ0000000fSAGMA2",
#         "profile_pic": "http://cloudspokes.s3.amazonaws.com/Cloud_th_100.jpg"
#     },
#     "comment": "test",
#     "member": "a0IJ0000000fSAGMA2",
#     "createddate": "2012-10-30T09:10:31.000+0000",
#     "id": "a09J0000003TRecIAG",
#     "challenge": "a0GJ0000002ZBv7MAG"
# },
