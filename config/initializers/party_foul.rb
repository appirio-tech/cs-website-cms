PartyFoul.configure do |config|
  # The collection of exceptions PartyFoul should not be allowed to handle
  # The constants here *must* be represented as strings
  config.blacklisted_exceptions = ['ActiveRecord::RecordNotFound', 'ActionController::RoutingError']

  # The OAuth token for the account that is opening the issues on Github
  config.oauth_token            = ENV['PARTY_FOUL_OAUTH_TOKEN']

  # The API endpoint for Github. Unless you are hosting a private
  # instance of Enterprise Github you do not need to include this
  config.endpoint               = 'https://api.github.com'

  # The Web URL for Github. Unless you are hosting a private
  # instance of Enterprise Github you do not need to include this
  config.web_url                = 'https://github.com'

  # The organization or user that owns the target repository
  config.owner                  = 'cloudspokes'

  # The repository for this application
  config.repo                   = 'cs-website-cms'

  # The branch for your deployed code
  # config.branch               = 'master'

  # Additional labels to add to issues created
  # config.additional_labels    = ['production']
  # or
  # config.additional_labels    = Proc.new do |exception, env|
  #   []
  # end
end
