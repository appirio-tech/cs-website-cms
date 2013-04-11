# class no longer needed!
class Category < ApiModel
  def self.api_endpoint
  	"#{ENV['CS_API_URL']}/categories"
  end

  def self.names
    @names ||= http_get 'categories'
  end
end