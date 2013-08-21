class Member < ApiModel
  require 'uri'

  attr_accessor :id, :name, :profile_pic, :attributes,
    :challenges_entered, :active_challenges, :time_zone,
    :total_1st_place, :total_2nd_place, :total_3st_place,
    :total_wins, :total_money, :total_points, :valid_submissions,
    :summary_bio, :quote, :percent_submitted,
    :first_name, :last_name, :email, :address_line1, :address_line2, :city, :zip, :state, :phone_mobile, :time_zone, :country,
    :preferred_payment, :paperwork_received, :paperwork_sent, :paperwork_year, :paypal_payment_address,
    :company, :school, :years_of_experience, :work_status, :shirt_size, :age_range, :gender,
    :website, :twitter, :github, :facebook, :linkedin, :badgeville_id, :can_judge

  has_many :recommendations
  has_many :challenges, parent: Member
  has_many :payments
  has_many :referrals

  def self.api_endpoint
    "members"
  end  

  def self.has_many_api_endpoint
    api_endpoint
  end    

  # Used for resourceful routes (instead of id)
  def to_param
    name
  end

  def self.search(keyword)
    http_get("members/search?keyword=#{keyword}")
  end        

  def all_challenges
    self.class.http_get "members/#{URI.escape(name)}/challenges"
  end

  def all_past_challenges(offset=0)
    self.class.http_get("members/#{URI.escape(name)}/challenges/past?offset=#{offset}")
  end        

  def active_challenges(all_challenges)
    all_challenges.active.map {|challenge| Challenge.new challenge}
  end  

  def watching_challenges(all_challenges)
    all_challenges.watching.map {|challenge| Challenge.new challenge}
  end    

  def past_challenges(all_challenges)
    all_challenges.past.map {|challenge| Challenge.new challenge}
  end

  def self.login_type(membername)
    http_get "members/#{URI.escape(membername)}/login_type"
  end

  def inbox
    self.class.http_get("messages/inbox/#{URI.escape(@name)}").map {|message| Message.new message}
  end  

  def from
    self.class.http_get("messages/from/#{URI.escape(@name)}").map {|message| Message.new message}
  end

  def create_badgeville_account
      # create the badgeville user
      Badgeville.create_user(@name, @email.downcase)
      #create the badgeville player
      player_id = Badgeville.create_player(@name.downcase, @email.downcase)
      unless player_id.nil?
        Badgeville.send_site_registration player_id
        # update sfdc with badgeville player id
        Member.http_put("members/#{URI.escape(@name)}", {"Badgeville_Id__c" => player_id})
      end      
  end      

  def update_country_from_ip(remote_ip)
    unless ['127.0.0.1', 'localhost'].include?(remote_ip)
      if @country.nil?
        geo_results = Geocoder.search(remote_ip)
        Member.http_put("members/#{URI.escape(@name)}", {"Country__c" => geo_results.first.data['country_name']})  unless geo_results.nil? 
      end
    end
  end    

  def update_login_location_from_ip(remote_ip)
    unless ['127.0.0.1', 'localhost'].include?(remote_ip)
      geo_results = Geocoder.search(remote_ip)
      Member.http_put("members/#{URI.escape(@name)}", {"Login_Location__Latitude__s" => geo_results.first.data['latitude'], 
        "Login_Location__Longitude__s" => geo_results.first.data['longitude']})  unless geo_results.nil? 
    end
  end   

  def update_last_login
      Member.http_put("members/#{URI.escape(@name)}", {"Last_Login__c" => DateTime.now.strftime("%-m/%-d/%Y %I:%M %p")}) 
  end     

end
