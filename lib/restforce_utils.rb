require 'uri' 

module RestforceUtils

  #
  # Returns an access_token from saleforce for a type of generic user (guest or admin)
  # * *Args*    :
  #   - user_type -> admin or guest credentials
  # * *Returns* :
    #   - Restforce client
  # * *Raises* :
  #   - ++ ->
  #  
  def self.access_token(user_type=:guest)
    client = Restforce.new :username => salesforce_username(user_type),
      :password       => salesforce_password(user_type),
      :client_id      => ENV['SFDC_CLIENT_ID'],
      :client_secret  => ENV['SFDC_CLIENT_SECRET'],
      :host           => ENV['SFDC_HOST']
    client.authenticate!.access_token
  end

  #
  # Returns a restforce client for a type of generic user (guest or admin)
  # * *Args*    :
  #   - user_type -> admin or guest credentials
  # * *Returns* :
    #   - Restforce client
  # * *Raises* :
  #   - ++ ->
  #  
  def self.client(user_type=:guest)
    client = Restforce.new :username => salesforce_username(user_type),
      :password       => salesforce_password(user_type),
      :client_id      => ENV['SFDC_CLIENT_ID'],
      :client_secret  => ENV['SFDC_CLIENT_SECRET'],
      :host           => ENV['SFDC_HOST']
    client.authenticate!
    client
  end

  #
  # Returns a restforce client from an access_token
  # * *Args*    :
  #   - access_token -> the oauth token to use
  # * *Returns* :
    #   - Restforce client
  # * *Raises* :
  #   - ++ ->
  #  
  def self.client_for_access_token(access_token)
    Restforce.new :oauth_token => access_token,
      :instance_url  => ENV['SFDC_INSTANCE_URL'],
      :host           => ENV['SFDC_HOST']
  end  

  #
  # Performs a soql query against salesforce
  # * *Args*    :
  #   - soql -> the soql query
  # * *Returns* :
    #   - a results object
  # * *Raises* :
  #   - ++ ->
  #  
  def self.query_salesforce(soql, access_token=nil, user_type=:guest)
    client = token_or_type_client(access_token, user_type)
    Forcifier::JsonMassager.deforce_json(client.query(soql))
  rescue Exception => e
    Rails.logger.fatal "[FATAL][RestforceUtils] Query exception: #{soql} -- #{e.message}" 
    nil
  end  

  #
  # Creates a new record in salesforce
  # * *Args*    :
  #   - params -> the hash of values for the new record
  # * *Returns* :
    #   - new record id
  # * *Raises* :
  #   - ++ ->
  #  
  def self.create_in_salesforce(sobject, params, access_token=nil, user_type=:guest)
    client = token_or_type_client(access_token, user_type)
    {:success => true, :message => client.create!(sobject, params)}      
  rescue Exception => e
    Rails.logger.fatal "[FATAL][RestforceUtils] Create exception: #{e.message}" 
    {:success => false, :message => e.message}    
  end

  #
  # Updates a new record in salesforce
  # * *Args*    :
  #   - sobject -> the sobject to update
  #   - params -> the hash of values for the new record
  # * *Returns* :
    #   - new record id
  # * *Raises* :
  #   - ++ ->
  #  
  def self.update_in_salesforce(sobject, params, access_token=nil, user_type=:guest)
    client = token_or_type_client(access_token, user_type)
    {:success => client.update!(sobject, params), :message => ''}      
  rescue Exception => e
    Rails.logger.fatal "[FATAL][RestforceUtils] Update exception: #{e.message}" 
    {:success => false, :message => e.message}    
  end  

  #
  # Upserts a record in salesforce
  # * *Args*    :
  #   - sobject -> the sobject to update
  #   - params -> the hash of values for the new record
  # * *Returns* :
    #   - new record id
  # * *Raises* :
  #   - ++ ->
  #  
  def self.upsert_in_salesforce(sobject, params, external_field_name, access_token=nil, user_type=:guest)
    client = token_or_type_client(access_token, user_type)
    {:success => client.upsert!(sobject, external_field_name, params), :message => ''}      
  rescue Exception => e
    puts e.message
    Rails.logger.fatal "[FATAL][RestforceUtils] Update exception: #{e.message}" 
    {:success => false, :message => e.message}    
  end    

  #
  # Makes generic destroy to delete a records in salesforce
  # * *Args*    :
  #   - sobject -> the sObject to create
  #   - id -> the id of the record to delete
  # * *Returns* :
    #   - a hash containing the following keys: success, message
  # * *Raises* :
  #   - ++ ->
  #  
  def self.destroy_in_salesforce(sobject, id, user_type=:guest)
    client(user_type).destroy!(sobject, id)
    {:success => true, :message => 'Record successfully deleted.'} 
  rescue Exception => e
    Rails.logger.fatal "[FATAL][RestforceUtils] Destroy exception for Id #{id}: #{e.message}" 
    {:success => false, :message => e.message}   
  end 

 #
  # Makes generic 'get' to CloudSpokes Apex REST services
  # * *Args*    :
  #   - url_string -> the string to be appended to teh end of the url
  # * *Returns* :
    #   - a results object
  # * *Raises* :
  #   - ++ ->
  #  
  def self.get_apex_rest(url_string, access_token=nil, user_type=:guest, version='v.9')
    client = token_or_type_client(access_token, user_type)
    Forcifier::JsonMassager.deforce_json(client.get(ENV['SFDC_APEXREST_URL']+"/#{version}"+"#{url_string}").body)
  end    

  #
  # Makes generic 'post' to CloudSpokes Apex REST services
  # * *Args*    :
  #   - url_string -> the string to be appended to teh end of the url
  # * *Returns* :
    #   - a results object
  # * *Raises* :
  #   - ++ ->
  #  
  def self.post_apex_rest(url_string, options, access_token=nil, user_type=:guest, version='v.9')
    client = token_or_type_client(access_token, user_type)
    Forcifier::JsonMassager.deforce_json(client.post(ENV['SFDC_APEXREST_URL']+"/#{version}"+
      "#{url_string}", options))
  end    

  #
  # Makes generic 'put' to CloudSpokes Apex REST services
  # * *Args*    :
  #   - url_string -> the string to be appended to teh end of the url
  # * *Returns* :
    #   - a results object
  # * *Raises* :
  #   - ++ ->
  #  
  def self.put_apex_rest(url_string, params={}, access_token=nil, user_type=:guest, version='v.9')
    client = token_or_type_client(access_token, user_type)
    Forcifier::JsonMassager.deforce_json(client.put(ENV['SFDC_APEXREST_URL']+"/#{version}"+
      "#{url_string}?#{params.to_param}"))
  end   

  #
  # Makes generic 'get' to CloudSpokes Apex REST services
  # and returns success
  # * *Args*    :
  #   - url_string -> the string to be appended to teh end of the url
  # * *Returns* :
    #   - true/false
  # * *Raises* :
  #   - ++ ->
  #  
  def self.get_apex_rest_return_boolean(url_string, version='v.9')
    success = false
    success = true if get(ENV['SFDC_APEXREST_URL']+"/#{version}"+
      "#{url_string}")['Success'].eql?('true')  
    success
  end  

  def self.get_member_by_id(id)
    results = query_salesforce("select id, name, sfdc_user__c 
      from member__c where id = '#{id}'", nil)
    results.first
  end  

  def self.get_member_by_name(membername)
    results = query_salesforce("select id, name, sfdc_user__c 
      from member__c where name = '#{membername}'", nil)
    results.first
  end    

  private

    #
    # Returns a restforce client depending upon if an access token
    # was passed or not. If not, grabs a user type specific token
    # * *Args*    :
    #   - access_token -> the access_token to use for the client
    #   - user_type -> the type of user to fetch a client for
    # * *Returns* :
      #   - true/false
    # * *Raises* :
    #   - ++ ->
    #  
    def self.token_or_type_client(access_token=nil, user_type)
      if access_token
        client_for_access_token(access_token) 
      else
        client(user_type) 
      end
    end

    def self.salesforce_username(type)
      return ENV['SFDC_ADMIN_USERNAME'] if type == :admin
      return ENV['SFDC_PUBLIC_USERNAME'] if type == :guest
    end

    def self.salesforce_password(type)
      return ENV['SFDC_ADMIN_PASSWORD'] if type == :admin
      return ENV['SFDC_PUBLIC_PASSWORD'] if type == :guest
    end    

end