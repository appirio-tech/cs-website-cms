class Account < ApiModel
  attr_accessor :username, :sfdc_username, :profile_pic, :email, :accountid, :time_zone

  attr_reader :user

  def self.api_endpoint
    "accounts"
  end 

  def self.find_by_service(name, provider = "cloudspokes")
    data = {
      service: provider,
      service_username: name
    }
    http_get "accounts/find_by_service", data
  end

  def initialize(user)
    @user = user
  end

  def create(params)
    self.class.http_post("accounts/create", params)
  end

  def activate
    self.class.http_get("accounts/activate/#{user.username}")
  end  

  def authenticate(password)
    data = {
      membername: user.username,
      password: password
    }
    self.class.http_post("accounts/authenticate", data)
  end

  def process_referral(referred_by)
    data = { referral_id_or_membername: referred_by }
    self.class.http_put("accounts/#{user.username}/referred_by", data)
  end

  def process_marketing(source, medium, name)
    data = { campaign_source: source, campaign_medium: medium, campaign_name: name }
    self.class.http_put("accounts/#{user.username}/marketing", data)
  end  

  # updates the member's user in sfdc with the devise change password token
  def update_password_token(token)
    data = { token: token }
    self.class.http_put("accounts/update_password_token/#{user.username}", data)
  end

  def update_password(token, new_password)
    data = {
      token: token,
      new_password: new_password
    }
    self.class.http_put("accounts/change_password_with_token/#{user.username}", data)
  end    

  def preferences
    self.class.http_get("accounts/#{user.username}/preferences").map {|p| Preference.new p}
  end

  def update_preferences(preferences, all_preferences)
    all_preferences = all_preferences.split(',')
    prefs = {}
    preferences.each_pair do |key, value|
      # change each element from "email" to "Email"
      methods = value.map {|v| v.capitalize}
      # always mark these as notify
      methods << 'Notify'
      prefs.merge!(Hash[key, methods.join(";")])
      all_preferences.delete_at(all_preferences.index(key))
    end
    # add in any preferences that were marked as don't notify
    all_preferences.each {|p| prefs.merge!(Hash[p, ''])}
    self.class.http_put("accounts/#{user.username}/preferences", { preferences: prefs.to_json })
  end  

  # this will be replaced with chatter rest call
  def activities
    RestforceUtils.query_salesforce("select id, teaser__c, title__c, url__c, image__c, private__c, 
      description__c, createddate from member_activity__c where member__r.name = '#{user.username}'
      order by createddate desc", nil, :admin)    
  end

end
