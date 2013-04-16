class SubmissionDeliverable < ApiModel
  attr_accessor :id, :type, :url, :username, :comments, :language, 
  	:username, :password, :hosting_platform, :deleted

  def self.api_endpoint
    "challenges"
  end

  def self.has_many_api_endpoint
    api_endpoint
  end    

  def challenge
  	Challenge.new raw_data.challenge__r
  end

end