require 'docusign_rest'

DocusignRest.configure do |config|
  config.username       = ENV['DOCUSIGN_USERNAME']
  config.password       = ENV['DOCUSIGN_PASSWORD']
  config.integrator_key = ENV['DOCUSIGN_INTEGRATOR_KEY']
  config.account_id     = ENV['DOCUSIGN_ACCOUNT_ID']
  config.endpoint       = ENV['DOCUSIGN_ENDPOINT']
  config.api_version    = ENV['DOCUSIGN_API_VERSION']
end
