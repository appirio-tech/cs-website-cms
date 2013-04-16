class Referral < ApiModel
  attr_accessor :id, :signup_date, :referral_money, :referral_id, :profile_pic, :membername, :first_year_money

  def self.api_endpoint
    "members"
  end 

  def self.has_many_api_endpoint
    api_endpoint
  end   
  
  def signup_date
    Time.parse(@signup_date) if @signup_date
  end

end