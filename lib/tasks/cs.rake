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