class Scorecard < ApiModel
  attr_accessor :name, :submitted_date, :money_awarded, :score, :prize_awarded, :place

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/challenges"
  end

  def member
    Member.new raw_data.member__r
  end  

  def judges_scores
  	raw_data.scorecard__r.records
  end

end