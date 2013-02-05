class ApiModel
  include ActiveModel::Model

  ENDPOINT_EXPIRY = ENV['CS_API_EXPIRY'].to_i

  cattr_accessor :access_token  

  # Implements the has_many relationship
  # Passing :parent as an option allows modification of the calling class
  # This is used mostly for has and belongs to many relationships, where
  # a model collection will have a different endpoint
  # Case in point: Members and Challenges
  def self.has_many(entity, options={})
    puts "======= calling has_many for #{entity}"
    # add in this relationship to the column_names table
    @column_names << entity.to_sym
    rel_column_names << entity.to_sym
    parent = options[:parent]
    puts "parent: #{parent}"

    # dynamically create a method on this instance that will reference the collection
    define_method("#{entity.to_sym}=") do |accessor_value|
      instance_variable_set("@#{entity.to_sym}", accessor_value)
    end

    define_method(entity.to_sym) do
      klass = entity.to_s.classify.constantize
      puts "klass #{klass}"
      puts "to_param: #{to_param} -- #{entity.to_s}"
      (parent || klass).raw_get_has_many([to_param, entity.to_s]).map do |e|
        next if e.respond_to?(:last) # we got an array instead of a Hashie::Mash
        klass.new e
      end
    end
  end

  # Overrides the attr_accesssor class method so we are able to capture and
  # then save the defined fields as column_names
  def self.attr_accessor(*vars)
    @column_names ||= []
    @column_names.concat( vars )
    super
  end

  # Returns the previously defined attr_accessor fields
  def self.column_names
    @column_names
  end

  def self.rel_column_names
    @rel_column_names ||= []
  end

  # Returns the api_endpoint. Note that you need to implement this method
  # in the child object
  def self.api_endpoint
    raise 'Please implement ::api_endpoint in the child object'
  end

  # Returns all the records from the CloudSpokes API
  def self.all
    request(:get, '', {}).map {|item| new item}
  end

  # Returns the first record
  # TODO: when the API supports it, simply request for the first record.
  # There should be no need to request for all the records first.
  def self.first
    all.first
  end

  # Finds an entity (i.e., /members/jeffdonthemic) and any supported params {fields: 'id,name'}
  def self.find(entity, params={})
    puts "========== running find for #{entity} for #{self.name} with params #{params}"
    Kernel.const_get(self.name).new(raw_get entity, params)
  end

  # Wrap initialize with a sanitation clause
  def initialize(params={})
    @raw_data = params.dup
    params.delete_if {|k, v| !self.class.column_names.include? k.to_sym}
    super(params)
  end

  # Returns the raw data that created this object
  def raw_data
    @raw_data
  end

  # Returns if this record has the id attribute set (used by url_for for routing)
  def persisted?
    !!id
  end

  def save
    new_record? ? create : update
  end

  def update_attributes(attrs={})
    attrs.each do |attr, value|
      self.public_send("#{attr}=", value)
    end
    save
  end

  def new_record?
    id.blank?
  end

  def self.create(attrs)
    obj = new(attrs)
    obj.save
    obj
  end

  def self.api_request_headers
    {
      'oauth_token' => access_token,
      'Authorization' => 'Token token="'+ENV['CS_API_KEY']+'"',
      'Content-Type' => 'application/json'
    }
  end

  # Convenience method to request an entity from the CloudSpokes RESTful source
  # Accepts an array or a string
  # If given an array, will join the elements with '/'
  # If given a string, will use the argument as is
  def self.raw_get(entities = [], params)
    endpoint = endpoint_from_entities(entities)
    endpoint << "?#{params.to_param}" unless params.empty?
    puts "=====$$$$$ CALLING RAW GET #{entities} for #{endpoint}"
    #Rails.cache.fetch("#{endpoint}", expires_in: ENDPOINT_EXPIRY.minutes) do
      get_response(RestClient.get(endpoint, api_request_headers))
    #end
  end

  def self.raw_get_has_many(entities = [], params)
    endpoint = endpoint_from_entities(entities)
    endpoint << "/#{params.to_param}" unless params.empty?
    #Rails.cache.fetch("#{endpoint}", expires_in: ENDPOINT_EXPIRY.minutes) do
      get_response(RestClient.get(endpoint, api_request_headers))
    #end
  end  

  # Sanitized response to only the attributes we've defined
  def self.get(entity = '')
    raw_get(entity).delete_if {|k, v| !column_names.include? k.to_sym}
  end

  def self.endpoint_from_entities(entities = [])
    entities = entities.respond_to?(:join) ? entities.join("/") : entities.to_s
    entities.present? ? "#{api_endpoint}/#{entities}" : api_endpoint
  end

  def self.get_response(data)
    Hashie::Mash.new(JSON.parse(data)).response
  end

  def self.request(method, entities, data)
    endpoint = endpoint_from_entities(entities)  
    if method.to_sym == :get
      endpoint += "?#{data.to_param}"
      puts "===== request method endpoint: #{endpoint}"  
      resp = RestClient.send method, endpoint, api_request_headers
    else
      puts "===== request method endpoint: #{endpoint}"  
      data = data.to_json unless data.is_a?(String)
      resp = RestClient.send method, endpoint, data, api_request_headers
    end
    get_response(resp)
  end

  def self.post(entities, data)
    puts "======= calling post with: #{data}"
    request :post, entities, data
  end

  def self.put(entities, data)
    request :put, entities, data
  end

  private

    def save_data
      columns = self.class.column_names - self.class.rel_column_names - [:id]
      columns.inject({}) do |ret, column|
        val = self.public_send(column)
        ret[column] = val if val.present?
        ret
      end
    end

    # define update_endpoint to subclass if you want to use another url for update
    def update_endpoint
      id
    end

    # define create_endpoint to subclass if you want to use another url for create
    def create_endpoint
      ""
    end

    def update
      self.class.put update_endpoint, save_data
    end

    def create
      self.class.post create_endpoint, save_data
    end
end
