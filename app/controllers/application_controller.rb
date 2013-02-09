class ApplicationController < ActionController::Base
  protect_from_forgery

  #rescue_from ApiExceptions::EntityNotFoundError, :with => :not_found
  #rescue_from ApiExceptions::AccessDenied, :with => :access_denied

  before_filter :set_access_token
  before_filter :set_gon_variables

  def set_access_token
    # ApiModel.access_token = current_user.try(:access_token) || guest_access_token
    ApiModel.access_token = current_access_token
  end    

  def set_gon_variables
    gon.cs_api_url = ENV['CS_API_URL']
    gon.website_url = ENV['WEBSITE_URL']
  end      

  def show_welcome_page?
    false
  end

  # def not_found
  #   redirect_to '/not_found'
  # end  

  # def access_denied
  #   redirect_to '/access_denied'
  # end    

  def guest_access_token
    puts "=========== using guest access token"
    guest_token = Rails.cache.fetch('guest_access_token', :expires_in => 2.minute) do
      client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
        :password       => ENV['SFDC_PUBLIC_PASSWORD'],
        :client_id      => ENV['SFDC_CLIENT_ID'],
        :client_secret  => ENV['SFDC_CLIENT_SECRET'],
        :host           => ENV['SFDC_HOST']
      client.authenticate!.access_token
    end
  end  

  def admin_access_token
    puts "=========== using admin access token"
    guest_token = Rails.cache.fetch('guest_access_token', :expires_in => 2.minute) do
      client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
        :password       => ENV['SFDC_PUBLIC_PASSWORD'],
        :client_id      => ENV['SFDC_CLIENT_ID'],
        :client_secret  => ENV['SFDC_CLIENT_SECRET'],
        :host           => ENV['SFDC_HOST']
      client.authenticate!.access_token
    end
  end    

  def member_access_token
    puts "=========== using member access token"
    current_user.access_token
  end  


  private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || challenges_path
  end  

  def current_access_token
    if current_user.nil?
      guest_access_token
    else
      if current_user.access_token
        puts "====== Has Access Token expired?: #{Time.now.utc} - #{current_user.updated_at} - expired #{Time.now.utc > 10.minutes.since(current_user.updated_at)}"
        # check and see if it's an hour old
        update_user_with_sfdc_info if Time.now.utc > 10.minutes.since(current_user.updated_at)
      else
        update_user_with_sfdc_info
      end
      current_user.access_token
    end
  end 

  def update_user_with_sfdc_info
    puts '########### //// UPDATE CURRENT USER WITH SFDC INFO //// ###########'
    # authenticate to sfdc with the admin's access token
    ApiModel.access_token = admin_access_token    

    # TODO --- just set the member's access token to the guest token
    # sfdc_authentication = Account.new(current_user).authenticate('12345678a')
    # current_user.access_token = sfdc_authentication.access_token
    sfdc_account = Account.find(current_user.username)
    user = User.find(current_user.id)
    user.access_token = guest_access_token
    user.sfdc_username = sfdc_account.user.sfdc_username
    user.email = sfdc_account.user.email
    user.profile_pic = sfdc_account.user.profile_pic
    user.accountid = sfdc_account.user.accountid  
    # user.skip_confirmation!
    puts "====== COULD NOT SAVE USER WITH SFDC INFO: #{user.errors.full_messages}" if !user.save

  end

end
