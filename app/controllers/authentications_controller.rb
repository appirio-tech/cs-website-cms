class AuthenticationsController < ApplicationController

  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      redirect_to authentications_url, :notice => "Authentication successfull."      
    else
      user =  User.new
      user.apply_omniauth(omniauth)
      user.skip_confirmation! unless omniauth['provider'] == "twitter" # Since user is authenticated using omniauth then no need to send confirmation email
      user.create_account
      if user.save
        user.roles << Role.find_by_title('Refinery')
        user.roles << Role.find_by_title('Superuser')      
        user.update_attribute(:confirmed_at, DateTime.now)
        flash[:notice] = "Signed in successfully."
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    redirect_to authentications_url, :notice => "Successfully signed out."
  end
end
