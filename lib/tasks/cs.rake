require 'librato'

desc "Returns a salesforce.com access token for the current environment for the public user"
task :get_public_access_token => :environment do
	client = Restforce.new :username => ENV['SFDC_PUBLIC_USERNAME'],
	  :password       => ENV['SFDC_PUBLIC_PASSWORD'],
	  :client_id      => ENV['SFDC_CLIENT_ID'],
	  :client_secret  => ENV['SFDC_CLIENT_SECRET'],
	  :host           => ENV['SFDC_HOST']
	access_token = client.authenticate!.access_token 
	puts "Public access token for #{ENV['SFDC_HOST']}: #{access_token}"
end

# this task will not work properly unless administrator credentials are setup
desc "Returns a salesforce.com access token for the current environment for the admin user"
task :get_admin_access_token => :environment do
	client = Restforce.new :username => ENV['SFDC_ADMIN_USERNAME'],
	  :password       => ENV['SFDC_ADMIN_PASSWORD'],
	  :client_id      => ENV['SFDC_CLIENT_ID'],
	  :client_secret  => ENV['SFDC_CLIENT_SECRET'],
	  :host           => ENV['SFDC_HOST']
	access_token = client.authenticate!.access_token 
	puts "Admin access token for #{ENV['SFDC_HOST']}: #{access_token}"
end

desc "Updates postgres with new feed items"
task :update_rss_feeds => :environment do
	puts "Update news feed from RSS"
	CloudspokesFeed.update_news_from_feed
	puts "Update posts feed from RSS"
	CloudspokesFeed.update_posts_from_feed
end

desc "Creates new badgeville users"
task :create_badgeville_users => :environment do

  client = Restforce.new :username => ENV['SFDC_ADMIN_USERNAME'],
    :password       => ENV['SFDC_ADMIN_PASSWORD'],
    :client_id      => ENV['SFDC_CLIENT_ID'],
    :client_secret  => ENV['SFDC_CLIENT_SECRET'],
    :host           => ENV['SFDC_HOST']
  access_token = client.authenticate!.access_token 

  puts "Querying for members without badgeville ids"
  members = client.query("select id, name, email__c, badgeville_id__c from member__c where 
    badgeville_id__c = '' order by createddate desc limit 500")
  members.each do |m|
    member = Member.find(m.Name, { fields: 'id,email,name' })
    member.create_badgeville_account
  end

end

desc "Sends daily stats to Librato"
task :send_librato_daily_stats => :environment do
  puts "Sending stats to librato..."
  Librato.send_daily_data
  puts "Done sending stats to librato."
end  