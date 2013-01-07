class Account < ApiModel
  attr_accessor :username, :sfdc_username, :profile_pic, :email, :accountid

  attr_reader :user

  class << self
    def api_endpoint
      APP_CONFIG[:cs_api][:accounts]
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

  def create
    self.class.post("create", data_for_create)
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


  private
  def data_for_create
    {username: user.username, email: user.email}.tap do |hash|
      if user_auth.present?
        # signed up with third-party
        hash[:provider] = user_auth.provider
        hash[:name] = user.username
        hash[:provider_username] = user.username
      else
        hash[:password] = user.password
      end
    end
  end

  def user_auth
    @user_auth ||= user.authentications.first
  end

end
