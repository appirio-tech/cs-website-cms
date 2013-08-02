require 'librato/metrics'

module Librato

  def self.send_daily_data

    client = RestforceUtils.client
    stats = client.get(ENV['SFDC_APEXREST_URL']+"/librato/daily")

    Rails.logger.info "Sending Librato stats: #{stats.to_yaml}"

    # temp -- just for testing. will setup new account, delete this one and use addon
    Librato::Metrics.authenticate 'jeff@jeffdouglas.com', '396625706a06736f295b6bcc1a8b9fa51e68e5d8d18fb63f7c9accf8976bb720'

    Librato::Metrics.submit :open_challenges_per_day => {:value => stats.body.open_challenges, :source => 'cloudspokes'}
    Librato::Metrics.submit :new_submissions_per_day => {:value => stats.body.new_submissions, :source => 'cloudspokes'}
    Librato::Metrics.submit :scored_challenges_per_day => {:value => stats.body.scored_challenges, :source => 'cloudspokes'}
    Librato::Metrics.submit :new_comments_per_day => {:value => stats.body.new_comments, :source => 'cloudspokes'}

  end    

end