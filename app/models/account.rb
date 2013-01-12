class Account < ApiModel
  attr_accessor :username, :sfdc_username, :profile_pic, :email, :accountid

  attr_reader :user

  class << self
    def api_endpoint
      "#{ENV['CS_API_URL']}/accounts"
    end

    def find(access_token, name, provider = "cloudspokes")
      data = {
        service: provider,
        service_username: name
      }
      request access_token, :get, "find_by_service", data
    end
  end

  def initialize(user)
    @user = user
  end

  def create(access_token, params)
    self.class.post(access_token, "create", params)
  end

  def authenticate(access_token, password)
    data = {
      membername: user.username,
      password: password
    }
    self.class.post(access_token, "authenticate", data)
  end

  def reset_password(access_token)
    self.class.request(access_token, :get, ["reset_password", user.username], {})
  end

  def update_password(access_token, passcode, new_password)
    data = {
      passcode: passcode,
      new_password: new_password
    }
    self.class.put(access_token, ["update_password", user.username], data)
  end

end
