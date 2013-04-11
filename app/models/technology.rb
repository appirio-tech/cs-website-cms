class Technology < ApiModel
  def self.api_endpoint
    "#{ENV['CS_API_URL']}/technologies"
  end

  def self.names
    @names ||= http_get 'technologies'
  end
end