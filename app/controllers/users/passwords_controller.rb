class Users::PasswordsController < Devise::PasswordsController

  # 'new' shows the password reset form but not really using that
  # post the reqeust to reset the password -- via ajax
  def create
    # find out how the user is logging in
    login_type = Member.login_type params[:username].downcase
    # if we found a valid user
    if login_type
      if login_type.downcase.eql?('cloudspokes')
        user = User.find_by_username(params[:username].downcase)
        if user
          user.send_reset_password_instructions
          render :text => 'Check your inbox for password reset instructions.'
        else
          # fetch the user from sfdc and add to pg
          new_user = add_user_from_salesforce(params[:username])
          if new_user
            new_user.send_reset_password_instructions
            render :text => 'Check your inbox for password reset instructions.'
          else
            render :text => "User '#{params[:username]}' not found. Please contact support@cloudspokes.com."
          end
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
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    resource.username = user.username
    # change their reset token in sfdc
    Account.new(user).update_password_token(params[:reset_password_token])
  end  

  # when the user submits the password change form
  def update
    user = User.find_by_username(params[:user][:username].downcase)
    attributes = params[:user]
    if user and attributes[:password].present? and attributes[:password] == attributes[:password_confirmation]
      resp = user.account.update_password(attributes[:reset_password_token], attributes[:password])
      if resp.success == "true"
        user.reset_password!(attributes[:password], attributes[:password_confirmation])
        user.mav_hash = Encryptinator.encrypt_string attributes[:password]
        user.last_access_token_refresh_at = Date.yesterday
        user.save
        flash[:notice] = "Password changed successfully!"
        sign_in(resource_name, user)
        redirect_to after_sign_in_path_for(user)
      else
        # not DRY
        flash[:error]  = resp.message
        user = User.find_by_reset_password_token(attributes[:reset_password_token])
        self.resource = resource_class.new
        resource.reset_password_token = attributes[:reset_password_token]
        resource.username = user.username        
        render action: "edit"
      end
    else
      # not DRY
      flash[:error] = "Passwords do not match."
      user = User.find_by_reset_password_token(attributes[:reset_password_token])
      self.resource = resource_class.new
      resource.reset_password_token = attributes[:reset_password_token]
      resource.username = user.username
      render action: "edit"
    end
  end

  private 

    def add_user_from_salesforce(username)
      sfdc_account = Account.find(username)
      password = (0...8).map{(65+rand(26)).chr}.join # they will change this anyway
      user =  User.new
      user.username = username.downcase
      user.password = password
      user.email = sfdc_account.user.email
      user.mav_hash = Encryptinator.encrypt_string password
      user.last_access_token_refresh_at = Date.yesterday
      user.skip_confirmation!      
      # save their record, sign them in and redirect
      if user.save
        user
      else
        logger.info "[FATAL] Error saving new user for not_found password reset: #{user.errors.full_messages}" 
      end
    end

end