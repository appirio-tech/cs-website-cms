class Users::PasswordsController < Devise::PasswordsController

  # GET /resource/password/edit?reset_password_token=abcdef&username=testuser
  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    resource.username = params[:username]
  end

  def create
    user = User.find_by_username(params[:user][:username])
    if user
      resp = user.account.reset_password
      if resp.success == "true"
        flash[:notice] = "We send you a reset password instructions via email."
        redirect_to after_sending_reset_password_instructions_path_for(resource_name)
      else
        flash[:alert]  = resp.message
        render action: "new"
      end
    else
      flash[:alert] = "invalid username"
      render action: "new"
    end
  end

  def update
    user = User.find_by_username(params[:user][:username])
    attributes = params[:user]
    if user and attributes[:password].present? and attributes[:password] == attributes[:password_confirmation]
      resp = user.account.update_password(attributes[:rest_password_token], attributes[:password])
      if resp.success == "true"
        user.reset_password!(attributes[:password], attributes[:password_confirmation])
        flash[:notice] = "Password changed successfully!"
        sign_in(resource_name, user)
        redirect_to after_sign_in_path_for(user)
      else
        flash[:alert]  = resp.message
        render action: "edit"
      end
    else
      flash[:alert] = "invalid username"
      render action: "edit"      
    end
  end

end