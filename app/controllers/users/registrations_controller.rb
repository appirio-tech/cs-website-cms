class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource
    if @user.create_account
      super
      session[:omniauth] = nil unless @user.new_record?
    else
      respond_with resource
    end
  end
  
  private
  
  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end
end