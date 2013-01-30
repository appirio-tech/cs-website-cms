class Category < ApiModel
  def self.api_endpoint
  	"#{ENV['CS_API_URL']}/categories"
  end

  def self.names
    @names ||= request :get, nil, {}
  end
end