class AuthenticationsController < ApplicationController

  def index
    @authentications = current_user.authentications if current_user
  end

  def callback
    omniauth = request.env['omniauth.auth']
    # see if the user exists in sfdc
    sfdc_account = Account.find(thirdparty_username(omniauth), omniauth['provider'])
    #puts "sfdc_account: #{sfdc_account.to_yaml}"

    # successfully found a user in sfdc
    if sfdc_account.success.to_bool
      login_third_party(omniauth, sfdc_account)
    else
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
    redirect_to authentications_url, :notice => "Successfully signed out."
  end

  private 

    def login_third_party(omniauth, sfdc_account)
      activate_account_in_sfdc
      sfdc_authentication = Account.new(User.new(:username => sfdc_account.username)).authenticate(ENV['THIRD_PARTY_PASSWORD'])
      db_authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      # if the user is already in db
      if db_authentication
        update_user_with_sfdc_info(db_authentication.user_id, sfdc_account, sfdc_authentication)
        flash[:notice] = "Signed in successfully (login_third_party authenticate)."
        sign_in_and_redirect(:user, User.find(db_authentication.user_id)) 
      # if current user
      elsif current_user
        current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
        redirect_to authentications_url, :notice => "Authentication successfull."         
      # create a new user
      else
        user =  User.new
        user.apply_omniauth(omniauth)
        # set the sfdc values
        user.access_token = sfdc_authentication.access_token
        user.sfdc_username = sfdc_account.sfdc_username
        user.profile_pic = sfdc_account.profile_pic
        user.accountid = sfdc_account.accountid
        user.username = sfdc_account.username
        user.skip_confirmation! unless omniauth['provider'] == "twitter" # Since user is authenticated using omniauth then no need to send confirmation email
        user.create_account
        if user.save
          #user.roles << Role.find_by_title('Refinery')
          #user.roles << Role.find_by_title('Superuser')      
          user.update_attribute(:confirmed_at, DateTime.now)
          flash[:notice] = "Signed in successfully (login_third_party new user)."
          sign_in_and_redirect(:user, user)
        # error saving, send them back
        else
          session[:omniauth] = omniauth.except('extra')
          redirect_to new_user_registration_url
        end

      end

    end

    def activate_account_in_sfdc
      # TODO - call sfdc to activate account
    end

    # update database with their info from sfdc
    def update_user_with_sfdc_info(id, sfdc_account_info, sfdc_authentication)
      puts "sfdc_account_info #{sfdc_account_info.to_yaml}"
      puts "sfdc_authentication #{sfdc_authentication.to_yaml}"
      u = User.find(id)
      u.access_token = sfdc_authentication.access_token
      u.sfdc_username = sfdc_account_info.sfdc_username
      u.profile_pic = sfdc_account_info.profile_pic
      u.accountid = sfdc_account_info.accountid
      if u.save
        puts "========== user successfully updated in pg with access token"
        puts u.to_yaml
      # error saving, send them back
      else
        puts "========== ERROR updating in pg with access token"
        puts u.errors.full_messages
      end      
      u.save
    end

    def thirdparty_username(omniauth)
      if ['github','twitter'].include?(omniauth[:provider]) 
        omniauth['info']['nickname']
      else
        omniauth['info']['email']
      end
    end    

end