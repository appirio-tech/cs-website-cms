class Category < ApiModel
  attr_accessor :id, :attributes,
    :name, :color

  def self.api_endpoint
  	"#{ENV['CS_API_URL']}/categories"
  end

  def self.names
    #all.map {|category| category.name}
    ['dummy','data']
  end
end