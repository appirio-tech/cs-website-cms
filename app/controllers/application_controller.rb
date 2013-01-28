class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_access_token

  def set_access_token
    # ApiModel.access_token = current_user.try(:access_token) || guest_access_token
    ApiModel.access_token = current_access_token
  end    

  def show_welcome_page?
    #overriding refinery initialization wizard behavior, so unpopulated test
    #database will successfully run.
    false
  end


  private

  def after_sign_in_path_for(resource)
    puts "========== redirect to #{stored_location_for(resource)}"
    stored_location_for(resource) || challenges_path
  end  

  # TODO - this will eventually pull the access token from the current_user
  # if present or use the guest user access_token
  def current_access_token
    client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
      :password       => ENV['SFDC_PUBLIC_PASSWORD'],
      :client_id      => ENV['SFDC_CLIENT_ID'],
      :client_secret  => ENV['SFDC_CLIENT_SECRET'],
      :host           => ENV['SFDC_HOST']
    client.authenticate!.access_token
  end

end
