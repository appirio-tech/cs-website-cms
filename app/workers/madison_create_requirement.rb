class MadisonCreateRequirement

  @queue = :madison_create_requirement
  def self.perform(req)
    
      id = RestforceUtils.query_salesforce("select Id from Challenge__c 
        where Challenge_Id__c = '#{req['challenge_id']}'", nil, :admin).first.id 

      data = {}
      data[:description__c] = req['description']
      data[:section__c] = req['section']
      data[:challenge__c] = id
      data[:madison_id__c] = req['id']
      data[:order_by__c] = req['order_by']
      data[:scoring_type__c] = req['scoring_type']
      data[:weight__c] = req['weight']
      results = RestforceUtils.create_in_salesforce('Challenge_Requirement__c', data, nil, :admin)

  rescue Exception => e
    puts e.message
  end  

end