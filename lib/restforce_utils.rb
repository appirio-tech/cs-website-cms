require 'uri' 

module RestforceUtils

  #
  # Returns an access_token from saleforce
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
  # Returns a restforce client
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
  # Performs a soql query against salesforce
  # * *Args*    :
  #   - soql -> the soql query
  # * *Returns* :
    #   - a results object
  # * *Raises* :
  #   - ++ ->
  #  
  def self.query_salesforce(soql, user_type=:guest)
    Forcifier::JsonMassager.deforce_json(client(user_type).query(soql))
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
  def self.create_in_salesforce(sobject, params, user_type=:guest)
    {:success => true, :message => client(user_type).create!(sobject, params)}      
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
  def self.update_in_salesforce(sobject, params, user_type=:guest)
    {:success => client(user_type).update!(sobject, params), :message => ''}      
  rescue Exception => e
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
  def self.get_apex_rest(url_string)
    Forcifier::JsonMassager.deforce_json(get(ENV['SFDC_APEXREST_URL']+"#{url_string}"))
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
  def self.post_apex_rest(url_string, options)
    Forcifier::JsonMassager.deforce_json(post(ENV['SFDC_APEXREST_URL']+"#{url_string}", options))
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
  def self.put_apex_rest(url_string, params={})
    Forcifier::JsonMassager.deforce_json(put(ENV['SFDC_APEXREST_URL']+"#{url_string}?#{params.to_param}"))
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
  def self.get_apex_rest_return_boolean(url_string)
    success = false
    success = true if get(ENV['SFDC_APEXREST_URL'] + 
      "#{url_string}")['Success'].eql?('true')  
    success
  end  

  private

    def self.salesforce_username(type)
      return ENV['SFDC_ADMIN_USERNAME'] if type == :admin
      return ENV['SFDC_PUBLIC_USERNAME'] if type == :guest
    end

    def self.salesforce_password(type)
      return ENV['SFDC_ADMIN_PASSWORD'] if type == :admin
      return ENV['SFDC_PUBLIC_PASSWORD'] if type == :guest
    end    

end