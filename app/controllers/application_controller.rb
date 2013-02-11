class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ApiExceptions::EntityNotFoundError, :with => :not_found
  rescue_from ApiExceptions::AccessDenied, :with => :access_denied

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

  def not_found
    redirect_to '/not_found'
  end  

  def access_denied
    redirect_to '/access_denied'
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
        puts "===== current user is nil"
        guest_access_token
      else
        puts "===== current_user exists"
        if current_user.access_token
          puts "===== current_user access token exists"
          puts "====== Has Access Token expired?: #{Time.now.utc} > 5minutes past #{current_user.last_access_token_refresh_at} - expired #{Time.now.utc > 5.minutes.since(current_user.last_access_token_refresh_at)}"
          # check and see if it's an hour old
          if Time.now.utc > 5.minutes.since(current_user.last_access_token_refresh_at)
            puts "===== current_user access token expired"
            token = update_user_with_sfdc_info
            puts "===== returning new access token that expired: #{token}"
            token          
          else
            puts "===== returning current_user's access token"
            #authenticate_for_access_token
            current_user.access_token
          end
        else
          puts "===== current_user access token is nil"
          token = update_user_with_sfdc_info
          puts "===== returning new access token: #{token}"
          token
        end
      end
    end 

    def update_user_with_sfdc_info
      puts '########### //// UPDATE CURRENT USER WITH SFDC INFO //// ###########'
      # authenticate to sfdc with the admin's access token
      ApiModel.access_token = admin_access_token    

      # TODO --- just set the member's access token to the guest token
      # sfdc_authentication = Account.new(current_user).authenticate('12345678a')
      # current_user.access_token = sfdc_authentication.access_token
      puts "===== calling find to the sfdc info"
      sfdc_account = Account.find(current_user.username)
      user = User.find(current_user.id)
      user.access_token = refresh_access_token_from_sfdc
      user.sfdc_username = sfdc_account.user.sfdc_username
      user.email = sfdc_account.user.email
      user.profile_pic = sfdc_account.user.profile_pic
      user.accountid = sfdc_account.user.accountid
      user.last_access_token_refresh_at = DateTime.now
      # user.skip_confirmation!
      puts "===== saving user with updated sfdc info to db"
      puts "====== COULD NOT SAVE USER WITH SFDC INFO: #{user.errors.full_messages}" if !user.save
      puts "===== current_user after save: #{user.to_yaml}"
      # return the new access token
      user.access_token
    end

    def refresh_access_token_from_sfdc
      puts "==== %%%%% calling refresh_access_token_from_sfdc"
      mav_hash = current_user.mav_hash.nil? ? ENV['THIRD_PARTY_PASSWORD'] : current_user.mav_hash
      sfdc_authentication = Account.new(current_user).authenticate(mav_hash)
      if sfdc_authentication.success.to_bool
        sfdc_authentication.access_token
      else
        # check for any authentication errors and return guest token if error
        guest_access_token
        puts "[FATAL][ApplicationController]: Could not refresh #{current_user.username}'s access token: #{sfdc_authentication.message}"
      end
    end

end
