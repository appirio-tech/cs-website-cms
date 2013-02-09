class Community < ApiModel
  attr_accessor :name, :community_id, :about, :members

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/communities"
  end

end