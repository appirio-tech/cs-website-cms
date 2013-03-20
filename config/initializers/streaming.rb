require 'restforce'
require 'faye'

# Initialize a client with your username/password.
client = Restforce.new :username => ENV['SFDC_ADMIN_USERNAME'],
  :password       => ENV['SFDC_ADMIN_PASSWORD'],
  :client_id      => ENV['SFDC_CLIENT_ID'],
  :client_secret  => ENV['SFDC_CLIENT_SECRET'],
  :host           => ENV['SFDC_HOST']  

begin
  puts "[DEBUG][STREAMING] Starting up restforce"
  client.authenticate!
  puts "[DEBUG][STREAMING] Started!"
  Rails.logger.debug "[DEBUG][STREAMING] Successfully authenticated"

  EM.next_tick do
    client.subscribe 'ChallengeFireHose' do |message|
      Rails.logger.info "[INFO][STREAMING]Received message #{message['sobject']['Id']}"
    end
  end

rescue
  Rails.logger.fatal "[FATAL][STREAMING] Could not authenticate. Not listening for streaming events."
end