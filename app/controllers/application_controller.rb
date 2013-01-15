class ApplicationController < ActionController::Base
  protect_from_forgery

  def show_welcome_page?
    #overriding refinery initialization wizard behavior, so unpopulated test
    #database will successfully run.
    false
  end


  private

  def after_sign_in_path_for(user)
    "/about"
  end  

  # TODO - this will eventually pull the access token from the current_user
  # if present or use the guest user access_token
  def access_token
    client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
      :password       => ENV['SFDC_PUBLIC_PASSWORD'],
      :client_id      => ENV['SFDC_CLIENT_ID'],
      :client_secret  => ENV['SFDC_CLIENT_SECRET'],
      :host           => ENV['SFDC_HOST']
    logger.info client.to_yaml
    client.authenticate!.access_token
  end


end
