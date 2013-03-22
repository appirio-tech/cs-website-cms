require 'restforce'
require 'faye'

# Initialize a client with your username/password.
$restforce = Restforce.new :username => ENV['SFDC_ADMIN_USERNAME'],
  :password       => ENV['SFDC_ADMIN_PASSWORD'],
  :client_id      => ENV['SFDC_CLIENT_ID'],
  :client_secret  => ENV['SFDC_CLIENT_SECRET'],
  :host           => ENV['SFDC_HOST']  

begin
  $restforce.authenticate!
  Rails.logger.debug "[DEBUG][STREAMING] Successfully authenticated"
rescue
  Rails.logger.fatal "[FATAL][STREAMING] Could not authenticate. Not listening for streaming events."
end