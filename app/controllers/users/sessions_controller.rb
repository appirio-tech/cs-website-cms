class Users::SessionsController < Devise::SessionsController
  before_filter :authenticate_account, only: [:create]

  protected

  # signs a user in with their email and password
  def authenticate_account
    user = User.find_by_username(params[:user][:username])
    if user
      resp = user.account.authenticate(params[:user][:password])
      if resp.success == "true"
        user.update_attribute(:access_token, resp.access_token)
        sign_in_and_redirect(:user, user)
      else
        flash[:alert]  = resp.message
        render action: "new"
      end
    end
  end

end