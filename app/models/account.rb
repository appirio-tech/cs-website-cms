class Account < ApiModel
  attr_accessor :username, :sfdc_username, :profile_pic, :email, :accountid

  attr_reader :user

  class << self
    def api_endpoint
      "#{ENV['CS_API_URL']}/accounts"
    end

    def find(name, provider = "cloudspokes")
      data = {
        service: provider,
        service_username: name
      }
      request :get, "find_by_service", data
    end
  end

  def initialize(user)
    @user = user
  end

  def create(params)
    self.class.post("create", params)
  end

  def authenticate(password)
    data = {
      membername: user.username,
      password: password
    }
    self.class.post("authenticate", data)
  end

  def reset_password
    self.class.request(:get, ["reset_password", user.username], {})
  end

  def update_password(passcode, new_password)
    data = {
      passcode: passcode,
      new_password: new_password
    }
    self.class.put(["update_password", user.username], data)
  end

end
