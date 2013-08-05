class Users::RegistrationsController < Devise::RegistrationsController

  # called from 'register' modal via jquery POST to create a user
  def create
    render :text => create_member_from_email(params[:user])
  end

  # it WAS the new user signup form but now simply tells them to hit register button
  def new
  end

  def signup
    # check for google marketing info to store for the member
    if params[:utm_source] && params[:utm_medium] && params[:utm_campaign]
      cookies[:marketing_campaign_source] = params[:utm_source]
      cookies[:marketing_campaign_medium] = params[:utm_medium]
      cookies[:marketing_campaign_name] = params[:utm_campaign]
    end
    render 'new'
  end

  # /singup/:membername_or_id
  def referral
    @member = Member.find(params[:id], fields: 'id,name,profile_pic,total_wins,active_challenges,total_money')
    cookies[:referral_referred_by] = params[:id]
  end

  # displays the form after the callback for creating a new user, 
  # allows them to enter their username, email and name
  def new_third_party
    if params[:user]
      @signup_form = SignupFormThirdParty.new params[:user]
      if @signup_form.valid?
        create_member_from_third_party @signup_form
      else
        @signup_form.errors.full_messages.each {|msg| flash.now[:alert] = msg }
      end
    else
      @signup_form = SignupFormThirdParty.new session[:auth] 
    end
  rescue Exception => e
    redirect_to '/bad'
  end
  
  private

    def create_member_from_email(params)
      user = User.new(email: params[:email], username: params[:username], password: params[:password], 
        password_confirmation: params[:password_confirm])   
      user.username = params[:username]      
      user.mav_hash = Encryptinator.encrypt_string params[:password]
      user.last_access_token_refresh_at = Date.yesterday
      # try and create the user in sfdc
      results = Account.new(user).create params
      if results.success.to_bool
        if user.save
          message = "#{results.message} Please confirm your email address before logging in. Check your inbox."
          Resque.enqueue(PostUserCreate, user)
        else
          message = user.errors.full_messages
        end        
      else
        message = results.message
      end
      message
    end  

    def create_member_from_third_party(params)
      user = User.new(email: params.email, username: params.username, password: ENV['THIRD_PARTY_PASSWORD'], 
        password_confirmation: ENV['THIRD_PARTY_PASSWORD'])  
      user.apply_omniauth(session[:omniauth])
      user.username = params.username
      user.last_access_token_refresh_at = Date.yesterday
      # try and create the user in sfdc
      results = Account.new(user).create(params)
      if results.success.to_bool
        if user.save
          flash[:notice] = "#{results.message} Please confirm your email address before logging in. Check your inbox."
          Resque.enqueue(PostUserCreate, user) 
          redirect_to root_path
        else
          flash.now[:error] = user.errors.full_messages
        end
      else
        flash.now[:error] = results.message
      end
    end
  
end