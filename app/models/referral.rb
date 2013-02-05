class Referral < ApiModel
  attr_accessor :id, :signup_date, :referral_money, :referral_id, :profile_pic, :membername, :first_year_money

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/members"
  end
  
  def signup_date
    Time.parse(@signup_date) if @signup_date
  end

end