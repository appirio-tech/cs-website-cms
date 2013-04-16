class Judging < ApiModel
  def self.api_endpoint
  	"judging"
  end  

  def self.judging_queue
     http_get('judging').map {|challenge| Challenge.new challenge}
  end

  def self.add_judge(challenge_id, membername)
    http_post("judging/add", {:challenge_id => challenge_id, :membername => membername}).message
  end   

  def self.outstanding_reviews(membername)
  	http_get("judging/outstanding/#{membername}")
  end     

  def self.participant_scorecard(participant_id, judge_membername)
    http_get("judging/scorecard/#{participant_id}", {judge_membername: judge_membername})
  end

  def self.save_scorecard(participant_id, answers, data) 
    http_put("judging/scorecard/#{participant_id}", 
      {:answers => answers, :options => data})
  end

end