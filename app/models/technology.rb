class Technology < ApiModel
  def self.api_endpoint
    "#{ENV['CS_API_URL']}/technologies"
  end

  def self.names
    @names ||= request :get, nil, {}
  end
end