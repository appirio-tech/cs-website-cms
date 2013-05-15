class ApiModel
  include ActiveModel::Model

  cattr_accessor :access_token  

  # Implements the has_many relationship
  # Passing :parent as an option allows modification of the calling class
  # This is used mostly for has and belongs to many relationships, where
  # a model collection will have a different endpoint
  # Case in point: Members and Challenges
  def self.has_many(entity, options={})
    # add in this relationship to the column_names table
    @column_names << entity.to_sym
    rel_column_names << entity.to_sym
    parent = options[:parent]

    # dynamically create a method on this instance that will reference the collection
    define_method("#{entity.to_sym}=") do |accessor_value|
      instance_variable_set("@#{entity.to_sym}", accessor_value)
    end

    define_method(entity.to_sym) do
      klass = entity.to_s.classify.constantize
      (parent || klass).get_has_many([to_param, entity.to_s]).map do |e|
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
    http_get(api_endpoint).map {|item| new item}
  end

  # Returns the first record
  def self.first
    all.first
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

  # Finds an entity (i.e., /members/jeffdonthemic) and any supported params {fields: 'id,name'}
  def self.find(entity, params = nil)
    Kernel.const_get(self.name).new(http_get "#{self.api_endpoint}/#{entity}", params)
  end  

  def self.http_get(endpoint, params = nil)
    options = { headers: api_request_headers }
    options.merge!(query = {query: params}) if params.present?
    puts "#{ENV['CS_API_URL']}/#{endpoint}"
    process_response(HTTParty::get("#{ENV['CS_API_URL']}/#{endpoint}", options))
  end

  def self.http_post(endpoint, params)
    options = { 
      headers: api_request_headers, 
      body: params.to_json
    }
    process_response(HTTParty::post("#{ENV['CS_API_URL']}/#{endpoint}", options))
  end

  def self.http_put(endpoint, params)
    options = { 
      headers: api_request_headers, 
      query: params
    }
    process_response(HTTParty::put("#{ENV['CS_API_URL']}/#{endpoint}", options))
  end   

  def self.get_has_many(entities = [], params)
    endpoint = has_many_endpoint_from_entities(entities)
    endpoint << "/#{params.to_param}" unless params.empty?  
    http_get endpoint, params
  end 

  def self.has_many_endpoint_from_entities(entities = [])
    entities = entities.respond_to?(:join) ? entities.join("/") : entities.to_s
    entities.present? ? "#{has_many_api_endpoint}/#{entities}" : has_many_api_endpoint
  end   

  def self.process_response(response)
    # puts "Processing response: #{response.code}"
    case response.code
      when 200
        Hashie::Mash.new(response).response
      when 404
        raise ApiExceptions::EntityNotFoundError.new 
      when 401
        raise ApiExceptions::AccessDenied.new         
      when 500...600
        raise ApiExceptions::WTFError.new 
    end    
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
