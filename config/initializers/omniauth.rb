# require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider :facebook, ENV['FACEBOOK_ID'], ENV['FACEBOOK_SECRET'], {:scope => 'offline_access,user_birthday,email, read_stream, read_friendlists, friends_likes, friends_status'}
  provider :github, ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], {:scope => "user,repo,gist"}
	provider :open_id, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
	provider :salesforce, ENV['SALESFORCE_ID'], ENV['SALESFORCE_SECRET']
	provider OmniAuth::Strategies::SalesforceSandbox, ENV['SALESFORCE_SANDBOX_ID'], ENV['SALESFORCE_SANDBOX_SECRET']
end