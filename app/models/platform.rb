class Platform < ApiModel
  def self.api_endpoint
    "platforms"
  end  

  def self.names
    @names ||= http_get 'platforms'
  end
end