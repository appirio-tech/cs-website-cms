class Account < ApiModel
  attr_accessor :username, :sfdc_username, :profile_pic, :email, :accountid

  attr_reader :user

  class << self
    def api_endpoint
      "#{ENV['CS_API_URL']}/accounts"
    end

    def find_by_service(name, provider = "cloudspokes")
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

  # not sure why this is needed -- remove?
  # def update_password_token(token)
  #   data = { token: token }
  #   self.class.put(["update_password_token", user.username], data)
  # end

  def update_password(token, new_password)
    data = {
      token: token,
      new_password: new_password
    }
    self.class.put(["change_password_with_token", user.username], data)
  end    

  # DEPRECATED
  def reset_password
    self.class.request(:get, ["reset_password", user.username], {})
  end



end
