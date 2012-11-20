class Comment < ApiModel
  attr_accessor :id, :attributes,
  	:comment, :createddate, :member

  def self.api_endpoint
    APP_CONFIG[:cs_api][:challenges]
  end

  # Cleanup up the __r convention
  def initialize(params={})
    params['member'] = params.delete('member__r')
    super(params)
  end

  def createddate
    Date.parse(@createddate) if @createddate
  end

  # has_one :member
  # Note that we're not using the from data in the json because it
  # lacks many attributes. We simply just do another api call
  def member
    Member.find @member.name
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
