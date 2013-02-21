class IncrementChallengePageView
  
  @queue = :increment_challenge_page_view
  def self.perform(challenge_id)
  	Challenge.increment_page_views(challenge_id)
  end
  
end