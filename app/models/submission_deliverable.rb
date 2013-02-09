class SubmissionDeliverable < ApiModel
  attr_accessor :id, :type, :url, :username, :comments

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/challenges"
  end

  def challenge
  	Challenge.new raw_data.challenge__r
  end

end