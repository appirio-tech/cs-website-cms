class Participant < ApiModel
  def self.api_endpoint
    "#{ENV['CS_API_URL']}/challenges"
  end

  attr_accessor :id, :has_submission, :member, :status, :challenge, 
    :country, :total_wins, :total_public_money

  # Cleanup up the __r convention
  def initialize(params={})
    params['member'] = params.delete('member__r') if params['member__r']
    params['challenge'] = params.delete('challenge__r') if params['challenge__r']
    super(params)
  end

  def self.find_by_member(challenge_id, membername)
    Participant.new naked_get "participants/#{membername}/#{challenge_id}"
  rescue Exception
    # rest call returns nil if the member is not a participant     
  end

  def self.current_status(challenge_id, membername)
    participant = find_by_member(challenge_id, membername)
    return Participant.new :status => 'Not Registered' unless participant
    participant
  end   

  def self.change_status(challenge_id, membername, params)
    if find_by_member(challenge_id, membername).registered?
      naked_put "participants/#{membername}/#{challenge_id}", {'fields' => params}
    else
      naked_post "participants/#{membername}/#{challenge_id}", {'fields' => params}
    end
  end  

  # temp till we move to new submissions
  def current_submissions(challenge_id)
    self.class.naked_get "participants/#{member.name}/#{challenge_id}/current_submssions"
  end

  def submission_deliverables
    #self.class.raw_get_has_many([to_param, 'submissions']).map {|submission| Submission.new(submission)}
    puts challenge
    self.class.naked_get("participants/#{member.name}/#{challenge.challenge_id}/deliverables").map {|submission| SubmissionDeliverable.new(submission)}
  end

  def member
    Member.new @member
  end

  def challenge
    Challenge.new @challenge
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
