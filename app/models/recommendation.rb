class Recommendation < ApiModel
  attr_accessor :id, :attributes,
  :recommendation, :createddate, :from

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/members"
  end

  # Cleanup up the __r convention
  def initialize(params={})
    params['from'] = params.delete('recommendation_from__r')
    super(params)
  end

  def createddate
    Date.parse(@createddate) if @createddate
  end

  # has_one :from
  # Note that we're not using the from data in the json because it
  # lacks many attributes. We simply just do another api call
  def from
    Member.find @from.name
  end

end
