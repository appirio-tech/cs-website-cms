class Participant < ApiModel
  def self.api_endpoint
    "#{ENV['CS_API_URL']}/challenges"
  end

  attr_accessor :id, :has_submission, :member, :status, :challenge, 
    :country, :total_wins, :total_public_money, :override_submission_upload

  # Cleanup up the __r convention
  def initialize(params={})
    params['member'] = params.delete('member__r') if params['member__r']
    params['challenge'] = params.delete('challenge__r') if params['challenge__r']
    super(params)
  end

  # override because of structure of api_endpoint
  def self.find(id)
    Participant.new naked_get "participants/#{id}"
  end

  def self.find_by_member(challenge_id, membername)
    Participant.new naked_get "participants/#{membername}/#{challenge_id}"
  rescue Exception
    # rest call returns nil if the member is not a participant
    Participant.new(:status => 'Not Registered', :has_submission => false)
  end

  def self.change_status(challenge_id, membername, params)
    if find_by_member(challenge_id, membername).participating?
      naked_put "participants/#{membername}/#{challenge_id}", {'fields' => params}
    else
      naked_post "participants/#{membername}/#{challenge_id}", {'fields' => params}
    end
  end 

  def create_deliverable(challenge_id, membername, params)
    self.class.naked_post "participants/#{member.name}/#{challenge_id}/deliverable", params
  end

  # kicks off the squirrelforce process
  def deploy_deliverable(submission_deliverable_id)
    self.class.naked_get "squirrelforce/unleash_squirrel/#{submission_deliverable_id}"
  end   

  # temp till we move to new submissions
  def save_submission_file_or_url(challenge_id, params)
    self.class.naked_post "participants/#{member.name}/#{challenge_id}/submission_url_file", params
  end

  # temp till we move to new submissions
  def current_submissions(challenge_id)
    self.class.naked_get "participants/#{member.name}/#{challenge_id}/current_submssions"
  end

  # temp till we move to new submissions
  def delete_submission(challenge_id, submission_id)
    self.class.naked_get "participants/#{member.name}/#{challenge_id}/delete_submission_url_file?submission_id=#{submission_id}"
  end  

  def submission_deliverables
    #self.class.raw_get_has_many([to_param, 'submissions']).map {|submission| Submission.new(submission)}
    self.class.naked_get("participants/#{member.name}/#{challenge.challenge_id}/deliverables").map {|submission| SubmissionDeliverable.new(submission)}
  end

  # temp till we move to new submissions
  def find_submission(challenge_id, membername, submission_id)
    self.class.naked_get "participants/#{membername}/#{challenge_id}/submission/#{submission_id}"
  end    

  def member
    Member.new @member if @member
  end

  def challenge
    Challenge.new @challenge
  end

  # Typecast into Boolean
  def has_submission
    !!@has_submission
  end

  def participating?
    @status.eql?('Not Registered') ? false : true
  end    

  def registered?
    ['not registered', 'watching'].include?(@status.downcase) ? false : true
  end  

  def submitted?
    !['not registered', 'registered', 'watching'].include?(@status.downcase)
  end

  def status
    @status
  end

end
