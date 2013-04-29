class Category < ApiModel
  def self.api_endpoint
  	"categories"
  end

  def self.names
    @names ||= http_get 'categories'
  end
end