class Users::SessionsController < Devise::SessionsController
  before_filter :authenticate_account, only: [:create]

  protected

  # signs a user in with their email and password for cloudspokes
  # called via jquery post from the popup login modal. return json object
  # with success and message
  def authenticate_account

    ApiModel.access_token = guest_access_token

    account = Account.new(User.new(:username => params[:user][:username]))
    # activate their account in case inactive
    account.activate
    # authenticate their credentails against sfdc
    sfdc_authentication = account.authenticate(params[:user][:password])

    logger.info "[CS-USER][LOGIN] starting login process for #{params[:user][:username]}. sfdc_authentication #{sfdc_authentication.to_yaml}"

    # if they authenticated successfully
    if sfdc_authentication.success.to_bool
      logger.info "[CS-USER][LOGIN] authentication success"
      # see if the user exists in the database
      user = User.find_by_username(params[:user][:username].downcase)
      logger.info "[CS-USER][LOGIN] find user in db: #{user.to_yaml}"
      if user
        logger.info "[CS-USER][LOGIN] found the user in the db"
        # set the last refersh to yesterday so it will refresh
        user.last_access_token_refresh_at = Date.yesterday
        user.mav_hash = Encryptinator.encrypt_string params[:user][:password]
        if user.save
          logger.info "[CS-USER][LOGIN] updated user last_access_token_refresh_at successfully. signing in."
          sign_in(:user, user)
          Resque.enqueue(PostLogin, user.username, request.remote_ip)
          render :json => {:success => true, :message => 'Successfully signed in.' }
        else
          logger.info "[CS-USER][LOGIN] error updating with last_access_token_refresh_at: #{user.errors.full_messages}"
          render :json => {:success => false, :message => "Sorry... there was an error logging you in: #{user.errors.full_messages}" }
        end
      # user exists in sfdc but not in db so create a new record
      else
        begin
          logger.info "[CS-USER][LOGIN] did NOT find the user in the db"
          sfdc_account = Account.find(params[:user][:username])
          user =  User.new
          user.username = params[:user][:username]
          user.password = params[:user][:password]
          user.email = sfdc_account.user.email
          user.mav_hash = Encryptinator.encrypt_string params[:user][:password]
          user.last_access_token_refresh_at = Date.yesterday
          logger.info "[CS-USER][LOGIN] getting ready to save this user: #{user.to_yaml}"
          user.skip_confirmation!
          # save their record, sign them in and redirect
          if user.save
            logger.info "[CS-USER][LOGIN] user saved successfully. signing in."
            user.update_attribute(:confirmed_at, DateTime.now)
            sign_in(:user, user)
            render :json => {:success => true, :message => 'Successfully signed in.' }
          else
            logger.info "[CS-USER][FATAL] error saving new user: #{user.errors.full_messages}"
            render :json => {:success => false, :message => "Sorry... there was an error logging you in." }
          end
        rescue Exception => e
          logger.info "[CS-USER][FATAL] exception logging in: #{e.message}"
          render :json => {:success => false, :message => "Sorry... there was an error logging you in." }
        end
      end 

    else
      render :json => {:success => false, :message => 'Invalid username / password combination' }
    end

  end

end