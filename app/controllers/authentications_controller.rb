class AuthenticationsController < ApplicationController

  def index
    @authentications = current_user.authentications if current_user
  end

  def callback
    omniauth = request.env['omniauth.auth']
    # see if the user exists in sfdc
    sfdc_account = Account.find_by_service(thirdparty_username(omniauth), omniauth['provider'])
    logger.info "[OAUTH] callback started from oauth dance for #{thirdparty_username(omniauth)}"
    # successfully found a user in sfdc
    if sfdc_account.success.to_bool
      logger.info "[OAUTH] found the user in sfdc"
      login_third_party(omniauth, sfdc_account)
    else
      logger.info "[OAUTH] new user -- did not find the user in sfdc"
      # capture their variables and redirect them to the signup page
      session[:auth] = {:email => omniauth['info']['email'], 
        :name => omniauth['info']['name'], :username => omniauth['info']['nickname'], 
        :provider => omniauth['provider']}
      session[:omniauth] = omniauth.except('extra')
      redirect_to new_third_party_user_registration_path
    end

  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    redirect_to authentications_url
  end

  private 

    # user exists in sfdc -- make sure they exist in db and sign in
    def login_third_party(omniauth, sfdc_account)

      begin

        db_authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
        # if the user is already in db
        if db_authentication
          logger.info "[OAUTH] already in the authentications table. updating last token refersh and signing in"
          user = User.find(db_authentication.user_id)
          user.last_access_token_refresh_at = Date.yesterday
          user.save
          sign_in_and_redirect(:user, user) 
        # if current user -- not sure what this is doing?
        elsif current_user
          current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
          redirect_to authentications_url        
        # create a new user in db
        else
          logger.info "[OAUTH] Not in the db. Creating a new user."
          user =  User.new
          user.apply_omniauth(omniauth)
          user.username = sfdc_account.username
          user.email = sfdc_account.email
          user.last_access_token_refresh_at = Date.yesterday
          user.skip_confirmation!
          if user.save
            if sfdc_account.email.include?('@appirio.com') 
              user.roles << Role.find_by_title('Refinery')
              user.roles << Role.find_by_title('Superuser') 
            end 
            user.update_attribute(:confirmed_at, DateTime.now)
            sign_in_and_redirect(:user, user)
          # error saving, send them back
          else
            session[:omniauth] = omniauth.except('extra')
            # TODO - this is the wrong URL
            redirect_to new_user_registration_url
          end

        end

      rescue Exception => e
        logger.info "[OAUTH][FATAL] exception: #{e.message}"
        flash[:error]  = "Sorry... there was an error logging you in. We are actively working on this issue."
        redirect_to :root
      end

    end

    def thirdparty_username(omniauth)
      if ['github','twitter'].include?(omniauth[:provider]) 
        omniauth['info']['nickname']
      else
        omniauth['info']['email']
      end
    end    

end