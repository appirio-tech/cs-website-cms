class Users::SessionsController < Devise::SessionsController
  before_filter :authenticate_account, only: [:create]

  protected
  def authenticate_account
    user = User.find_by_username(params[:user][:username])
    if user
      resp = user.account.authenticate(access_token, params[:user][:password])
      if resp.success == "true"
        user.update_attribute(:access_token, resp.access_token)
      else
        flash[:alert]  = resp.message
        render action: "new"
      end
    end
  end

end