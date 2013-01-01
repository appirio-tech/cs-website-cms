require 'restforce'
require 'faye'

=begin
--- commented out for right now.

# Initialize a client with your username/password.
client = Restforce.new :username => ENV['SFDC_ADMIN_USERNAME'],
  :password       => ENV['SFDC_ADMIN_PASSWORD'],
  :client_id      => ENV['SALESFORCE_SANDBOX_ID'],
  :client_secret  => ENV['SALESFORCE_SANDBOX_SECRET'],
  :host           => ENV['SFDC_HOST']


  client.authenticate!
  puts 'Successfully authenticated to salesforce.com'

  EM.next_tick do
      
    # Subscribe to the PushTopic.
    client.subscribe 'AllMembers' do |message|
      id = message['sobject']['Id']
      puts "Caught member message for #{id}"
      members = client.query("select Name from Member__c where Id = '"+id+"' limit 1")
      member = members.first
      puts "Streamed member: #{member.Name}"
    end
    client.subscribe 'AllChallenges' do |message|
      id = message['sobject']['Id']
      challenges = client.query("select Name from Challenge__c where Id = '"+id+"' limit 1")
      challenge = challenges.first
      puts "Streamed challenge: #{challenge.Name}"
    end
    client.subscribe 'AllMails' do |message|
      id = message['sobject']['Id']
      puts "Caught member message for #{id}"
      mails = client.query("select To__c, From__c, Subject__c, Body__c from Mail__c where Id = '"+id+"' limit 1")
      mail = mails.first
      puts "Streamed mail: To: #{mail.To__c}\n \tFrom: #{mail.From__c}\n \tSubject: #{mail.Subject__c}\n \tBody: #{mail.Body__c}"
    end
  end

rescue
  puts "Could not authenticate. Not listening for streaming events."
end

=end
