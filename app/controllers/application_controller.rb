class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_access_token
  before_filter :set_gon_variables

  ACTIVE_CHALLENGE_STATUSES = ['Created', 'Review', 'Review - Pending']

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
        # check and see if it's an hour old
        update_user_with_sfdc_info if Time.now > 60.minutes.since(current_user.updated_at)
      else
        update_user_with_sfdc_info
      end
      current_user.access_token
    end
  end 

  def update_user_with_sfdc_info

    # authenticate to sfdc with the admin's access token
    ApiModel.access_token = admin_access_token    

    # TODO --- just set the member's access token to the guest token
    # sfdc_authentication = Account.new(current_user).authenticate('12345678a')
    # current_user.access_token = sfdc_authentication.access_token
    current_user.access_token = guest_access_token

    sfdc_account = Account.find(current_user.username, 'cloudspokes')
    current_user.sfdc_username = sfdc_account.sfdc_username
    current_user.email = sfdc_account.email
    current_user.profile_pic = sfdc_account.profile_pic
    current_user.accountid = sfdc_account.accountid
    # update the user in pg
    puts 'Error saving current_user with sfdc data: #current_user.errors.full_messages' unless current_user.save

  end

end
