class Platform < ApiModel
  def self.api_endpoint
    "#{ENV['CS_API_URL']}/platforms"
  end

  def self.names
    @names ||= request :get, nil, {}
  end
end