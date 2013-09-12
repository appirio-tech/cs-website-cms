class CsPlatform

  def self.stats
    stats = Rails.cache.fetch('platform_stats', :expires_in => 60.minute) do
      HTTParty.get("#{ENV['CS_API_URL']}/stats")['response']
    end
  end

  def self.tos(id)
    HTTParty.get("#{ENV['CS_API_URL']}/tos/#{id}")['response']
  end	

  def self.leaderboards(options = {:limit => nil})
    HTTParty.get("#{ENV['CS_API_URL']}/leaderboard_all?#{options.to_param}")['response']
  end

  def self.leaderboard_referral(access_token)
    HTTParty.get("#{ENV['CS_API_URL']}/leaderboard/referral")['response']
  end

  def self.docusign_document(access_token, id)
    RestforceUtils.query_salesforce("select id, name , envelope_id__c 
      from docusign_document__c where id = '#{id}'", access_token).first
  end  

end