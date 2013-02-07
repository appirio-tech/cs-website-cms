class Participant < ApiModel
  def self.api_endpoint
    "#{ENV['CS_API_URL']}/challenges"
  end

  attr_accessor :id, :has_submission, :member, :status, :challenge, 
    :country, :total_wins, :total_public_money

  # Cleanup up the __r convention
  def initialize(params={})
    params['member'] = params.delete('member__r')
    super(params)
  end

  def self.current_status(challenge_id, membername)
    participant = naked_get "participants/#{membername}/#{challenge_id}"
    if participant
      Participant.new naked_get "participants/#{membername}/#{challenge_id}"
    else
      Participant.new :status => 'Not Registered'
    end
  end   

  def self.change_status(challenge_id, membername, params)
    if current_status(challenge_id, membername).registered?
      naked_put "participants/#{membername}/#{challenge_id}", {'fields' => params}
    else
      naked_post "participants/#{membername}/#{challenge_id}", {'fields' => params}
    end
  end  

  # has_one :member
  # Note that we're not using the member data in the json because it
  # lacks many attributes. We simply just do another api call
  def member
    Member.find(@member.name)
  end

  # Typecast into Boolean
  def has_submission
    !!@has_submission
  end

  def registered?
    @status.eql?('Not Registered') ? false : true
  end  

  def submitted?
    !['not registered', 'registered', 'watching'].include?(@status.downcase)
  end

  def status
    @status
  end

end
