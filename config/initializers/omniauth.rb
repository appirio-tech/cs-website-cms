# require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider :facebook, ENV['YOUR_APP_ID'], ENV['YOUR_APP_SECRET'], {:scope => 'offline_access,user_birthday,email, read_stream, read_friendlists, friends_likes, friends_status'}
  provider :github, ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], {:scope => "user,repo,gist"}
	provider :open_id, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
end