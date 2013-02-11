class Users::PasswordsController < Devise::PasswordsController

  # 'new' shows the password reset form but not really using that
  # post the reqeust to reset the password -- via ajax
  def create
    # find out how the user is logging in
    login_type = Member.login_type params[:username]
    # if we found a valid user
    if login_type
      if login_type.downcase.eql?('cloudspokes')
        user = User.find_by_username(params[:username])
        if user
          user.send_reset_password_instructions
          render :text => 'Check your inbox for password reset instructions.'
        else
          render :text => "User '#{params[:username]}' not found."
        end                
      else
        render :text => "You are logging in with OAuth using #{login_type} so there is no need to reset your password. 
          Simply click on the #{login_type} icon at the top of our site to login using your #{login_type} 
          account."
      end
    else
      render :text => "User '#{params[:username]}' not found."
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef from email link
  def edit
    user = User.find_by_reset_password_token(params[:reset_password_token])
    user.account.update_password_token(params[:reset_password_token])
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    resource.username = user.username
  end  

  def update
    user = User.find_by_username(params[:user][:username])
    attributes = params[:user]
    if user and attributes[:password].present? and attributes[:password] == attributes[:password_confirmation]
      resp = user.account.update_password(attributes[:reset_password_token], attributes[:password])
      if resp.success == "true"
        user.reset_password!(attributes[:password], attributes[:password_confirmation])
        flash[:notice] = "Password changed successfully!"
        sign_in(resource_name, user)
        redirect_to after_sign_in_path_for(user)
      else
        flash[:error]  = resp.message
        render action: "edit"
      end
    else
      flash[:error] = "Passwords do not match."
      render action: "edit"      
    end
  end

end