class Platform < ApiModel
  def self.api_endpoint
    "#{ENV['CS_API_URL']}/platforms"
  end

  def self.names
    @names ||= http_get 'platforms'
  end
end