class Category < ApiModel
  attr_accessor :id, :attributes,
    :name, :color

  def self.api_endpoint
    'http://cs-api-sandbox.herokuapp.com/v1/categories'
  end

  def self.names
    all.map {|category| category.name}
  end
end