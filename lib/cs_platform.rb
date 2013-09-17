class CsPlatform

  def self.stats
    stats = Rails.cache.fetch('platform_stats', :expires_in => 60.minute) do
      tc_members = tc_member_count
      results = HTTParty.get("#{ENV['CS_API_URL']}/stats")['response']
      results['members'] = (results['members'].to_i + tc_members).to_s
      results
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

  private

    def self.tc_member_count
      tc_stats = HTTParty.get("http://community.topcoder.com/tc?module=BasicData&c=member_count&dsid=30")
      tc_stats['member_count']['row']['member_count'].to_i
    rescue Exception => e
      return 0
    end  

end