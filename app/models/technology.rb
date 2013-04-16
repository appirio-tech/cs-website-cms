class Technology < ApiModel
  def self.api_endpoint
    "technologies"
  end

  def self.names
    @names ||= http_get 'technologies'
  end
end