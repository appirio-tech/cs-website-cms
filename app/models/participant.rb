class Participant < ApiModel
  def self.api_endpoint
    APP_CONFIG[:cs_api][:challenges]
  end

  attr_accessor :id, :attributes, :has_submission, :member, :status, :challenge

  # Cleanup up the __r convention
  def initialize(params={})
    params['member'] = params.delete('member__r')
    super(params)
  end

  # has_one :member
  # Note that we're not using the member data in the json because it
  # lacks many attributes. We simply just do another api call
  def member
    Member.find(@member.name)
  end

  # Typecast into Boolean
  def has_submission
    !!@has_submission
  end

end
