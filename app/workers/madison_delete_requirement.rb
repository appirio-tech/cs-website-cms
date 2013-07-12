class MadisonDeleteRequirement

  @queue = :madison_delete_requirement
  def self.perform(req)

    id = RestforceUtils.query_salesforce("select Id from Challenge_Requirement__c 
      where Madison_ID__c = #{req['id']}", nil, :admin).first.id
    results = RestforceUtils.destroy_in_salesforce('Challenge_Requirement__c', id, :admin)

  rescue Exception => e
    puts e.message
  end  

end