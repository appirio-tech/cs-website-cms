class Users::SessionsController < Devise::SessionsController
  before_filter :authenticate_account, only: [:create]

  protected

  # signs a user in with their email and password for cloudspokes
  def authenticate_account

    ApiModel.access_token = guest_access_token
    # authenticate their credentails against sfdc
    sfdc_authentication = Account.new(User.new(:username => params[:user][:username]))
      .authenticate(params[:user][:password])

    puts "===[CS-USER][LOGIN] sfdc_authentication #{sfdc_authentication.to_yaml}"

    # if they authenticated successfully
    if sfdc_authentication.success.to_bool
      puts "===[CS-USER][LOGIN] authentication success"
      # see if the user exists in the database
      user = User.find_by_username(params[:user][:username])
      puts "===[CS-USER][LOGIN] find user: #{user.to_yaml}"
      if user
        puts "===[CS-USER][LOGIN] found the user in the db"
        # set the last refersh to yesterday so it will refresh
        user.last_access_token_refresh_at = Date.yesterday
        if user.save
          puts "===[CS-USER][LOGIN] updated user last_access_token_refresh_at successfully. signing in."
          sign_in_and_redirect(:user, user)
        else
          puts "===[CS-USER][LOGIN] error updating with last_access_token_refresh_at: #{user.errors.full_messages}"
          flash[:error]  = "Sorry... there was an error logging you in. We are actively working on this issue. #{user.errors.full_messages}"
          render action: "new" # sign_in page
        end
      # user exists in sfdc but not in db so create a new record
      else
        begin
          puts "===[CS-USER][LOGIN] did NOT find the user in the db"
          user =  User.new
          user.username = params[:user][:username]
          user.password = params[:user][:password]
          user.mav_hash = Encryptinator.encrypt_string params[:user][:password]
          user.last_access_token_refresh_at = Date.yesterday
          puts "===[CS-USER][LOGIN] getting ready to save this user: #{user.to_yaml}"
          user.skip_confirmation!
          puts "===[CS-USER][LOGIN] adding skip_confirmation"
          # save their record, sign them in and redirect
          if user.save
            puts "===[CS-USER][LOGIN] user saved successfully. signing in."
            user.update_attribute(:confirmed_at, DateTime.now)
            sign_in_and_redirect(:user, user)
          else
            puts "===[CS-USER][LOGIN] error saving new user: #{user.errors.full_messages}"
            flash[:error]  = "Sorry... there was an error logging you in. We are actively working on this issue. #{user.errors.full_messages}"
            render action: "new" # sign_in page
          end
        rescue Exception => e
          puts "===[CS-USER][LOGIN] exception: #{e.message}"
          flash[:error]  = "Sorry... there was an error logging you in. We are actively working on this issue."
          render action: "new" # sign_in page          
        end
      end 

    else     
      flash[:error]  = 'Invalid username / password combination' # sfdc_authentication.message
      render action: "new" # sign_in page
    end

  end

end