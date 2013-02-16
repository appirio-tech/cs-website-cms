class Judging < ApiModel
  def self.api_endpoint
  	"#{ENV['CS_API_URL']}/judging"
  end

  def self.judging_queue
     naked_get('judging').map {|challenge| Challenge.new challenge}
  end

  def self.add_judge(challenge_id, membername)
    naked_post("judging/add", {:challenge_id => challenge_id, :membername => membername}).message
  end   

  def self.outstanding_reviews(membername)
  	naked_get("judging/outstanding/#{membername}")
  end   

  def self.participant_scorecard(participant_id, judge_membername)
    naked_get("judging/scorecard/#{participant_id}?judge_membername=#{judge_membername}")
  end

  def self.save_scorecard(participant_id, answers, data) 
    naked_put("judging/scorecard/#{participant_id}", 
      {:answers => answers, :options => data})
  end     

end