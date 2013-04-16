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

end
