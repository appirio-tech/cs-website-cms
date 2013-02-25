class Member < ApiModel
  attr_accessor :id, :name, :profile_pic, :attributes,
    :challenges_entered, :active_challenges, :time_zone,
    :total_1st_place, :total_2nd_place, :total_3st_place,
    :total_wins, :total_public_money, :total_points, :valid_submissions,
    :summary_bio, :quote, :percent_submitted,
    :first_name, :last_name, :email, :address_line1, :address_line2, :city, :zip, :state, :phone_mobile, :time_zone, :country,
    :preferred_payment, :paperwork_received, :paperwork_sent, :paperwork_year, :paypal_payment_address,
    :company, :school, :years_of_experience, :work_status, :shirt_size, :age_range, :gender,
    :website, :twitter, :github, :facebook, :linkedin, :badgeville_id

  has_many :recommendations
  has_many :challenges, parent: Member
  has_many :payments
  has_many :referrals

  def self.api_endpoint
    "#{ENV['CS_API_URL']}/members"
  end

  # Used for resourceful routes (instead of id)
  def to_param
    name
  end

  def active_challenges
    active_challenges = []
    challenges.each do |c|
      if !c.challenge_participants.records.first.status.eql?('Watching') && c.active?
        active_challenges << c
      end
    end
    active_challenges
  end  

  def watching_challenges
    watching_challenges = []
    challenges.each do |c|
      if c.challenge_participants.records.first.status.eql?('Watching') && c.active?
        watching_challenges << c
      end
    end
    watching_challenges
  end    

  def past_challenges
    past_challenges = []
    challenges.each do |c|
      if c.challenge_participants.records.first.has_submission
        past_challenges << c
      end
    end
    past_challenges
  end

  def self.search(keyword)
    request(:get, "search", {:keyword => keyword})
      .map {|member| Member.new member}
  end

  def self.login_type(membername)
    request(:get, "#{membername}/login_type", nil)
  end

  # this is temp
  def inbox
    self.class.naked_get("messages/inbox/#{@name}").map {|message| Message.new message}
  end  

end
