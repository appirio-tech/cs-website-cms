class Users::SessionsController < Devise::SessionsController
  before_filter :authenticate_account, only: [:create]

  protected

  # signs a user in with their email and password
  def authenticate_account

    # authenticate to sfdc with the admin's access token
    ApiModel.access_token = admin_access_token
    # authenticate their credentails against sfdc
    sfdc_authentication = Account.new(User.new(:username => params[:user][:username]))
      .authenticate(params[:user][:password])

    # if they authenticated successfully
    if sfdc_authentication.success.to_bool
      # see if the user exists in the database
      user = User.find_by_username(params[:user][:username])
      if user
        # flush the access token so it will be reset
        user.access_token = nil
        user.save
        sign_in_and_redirect(:user, user)
      # user exists in sfdc but not in db so create a new record
      else
        user =  User.new
        user.username = params[:user][:username]
        user.password = params[:user][:password]
        user.skip_confirmation!
        user.create_account

        # save their record, sign them in and redirect
        if user.save
          user.update_attribute(:confirmed_at, DateTime.now)
          sign_in_and_redirect(:user, user)
        else
          flash[:alert]  = "Sorry... there was an error creating your user account. #{user.errors.full_messages}"
          render action: "new" # sign_in page
        end
      end 

    else     
      flash[:alert]  = 'Invalid username / password combination' # sfdc_authentication.message
      render action: "new" # sign_in page
    end

  end

end