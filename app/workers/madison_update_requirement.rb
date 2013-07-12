class MadisonUpdateRequirement

  @queue = :madison_update_requirement
  def self.perform(req)

    data = {}
    data[:description__c] = req['description']
    data[:section__c] = req['section']
    data[:madison_id__c] = req['id']
    data[:order_by__c] = req['order_by']
    data[:scoring_type__c] = req['scoring_type']
    data[:weight__c] = req['weight']
    results = RestforceUtils.upsert_in_salesforce('Challenge_Requirement__c', data, 'Madison_ID__c', nil, :admin)    

  rescue Exception => e
    puts e.message
  end  

end