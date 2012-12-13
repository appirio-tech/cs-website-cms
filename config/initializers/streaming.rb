require 'restforce'
require 'faye'

# Initialize a client with your username/password.
client = Restforce.new :username => 'peakpado@gmail.com',
  :password       => 'Lionking4',
  :security_token => 'nysj8BUUGmCabA8bMrwkmCFIN',
  :client_id      => '3MVG9QDx8IX8nP5TvJeQJc1XRuIaYl4.cRDhTDs90mHHCoBKH_DkqsAYJnw6gmAXuwHZx1ar6mcU2KvUvl72v',
  :client_secret  => '5737452143195133975'

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