require 'restforce'
require 'faye'

# Initialize a client with your username/password.
client = Restforce.new :username => 'your-username',
  :password       => 'your-password',
  :security_token => 'your-security-token',
  :client_id      => 'your-client-id',
  :client_secret  => 'your-client-secret'

client.authenticate!

EM.next_tick do
    
  # Subscribe to the PushTopic.
  client.subscribe 'AllMembers' do |message|
    id = message['sobject']['Id']
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
    mails = client.query("select To__c, From__c, Subject__c, Body__c from Mail__c where Id = '"+id+"' limit 1")
    mail = mails.first
    puts "Streamed mail: To: #{mail.To__c}\n \tFrom: #{mail.From__c}\n \tSubject: #{mail.Subject__c}\n \tBody: #{mail.Body__c}"
  end
end