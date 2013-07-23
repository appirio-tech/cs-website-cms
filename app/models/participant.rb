class Participant < ApiModel
  def self.api_endpoint
    "participants"
  end

  def self.has_many_api_endpoint
    "challenges"
  end  

  attr_accessor :id, :has_submission, :member, :status, :challenge, 
    :country, :total_wins, :total_money, :override_submission_upload,
    :apis, :paas, :languages, :technologies, :submission_overview

  # Cleanup up the __r convention
  def initialize(params={})
    params['member'] = params.delete('member__r') if params['member__r']
    params['challenge'] = params.delete('challenge__r') if params['challenge__r']
    super(params)
  end

  def self.find_by_member(challenge_id, membername)
    results = Participant.new http_get "participants/#{membername}/#{challenge_id}"
    puts results.to_yaml
    results
  rescue Exception => e
    puts 'Exception in find_by_member'
    puts e.message
    # rest call returns nil if the member is not a participant
    Participant.new(:status => 'Not Registered', :has_submission => false)
  end

  def self.change_status(challenge_id, membername, params)
    if find_by_member(challenge_id, membername).participating?
      http_put "participants/#{membername}/#{challenge_id}", {'fields' => params}
    else
      http_post "participants/#{membername}/#{challenge_id}", {'fields' => params}
    end
  end 

  def update
    params = {apis: apis, paas: paas, languages: languages, technologies: technologies, submission_overview: submission_overview }
    self.class.http_put "participants/#{member.name}/#{challenge.challenge_id}", {'fields' => params}
  end

  def send_message_to_thurgood_logger(text)
    # get the job id for the participant
    job_id = RestforceUtils.query_salesforce("select thurgood_job_id__c from 
      challenge_participant__c where id = '#{@id}'").first.thurgood_job_id
    Thurgood.send_message(job_id, text) if job_id
  end  

  def create_deliverable(challenge_id, membername, deliverable)
    self.class.http_post "participants/#{membername}/#{challenge_id}/deliverable", {data: deliverable}
  end

  def update_deliverable(challenge_id, membername, deliverable)
    massaged_deliverable = {}
    # remove the raw data data attributes so it doesn't get pushed to the api and crash it
    SubmissionDeliverable.column_names.each {|col| massaged_deliverable[col] = eval("deliverable.#{col}") }
    self.class.http_put "participants/#{membername}/#{challenge_id}/deliverable", {data: massaged_deliverable}
  end  

  # temp till we move to new submissions
  def save_submission_file_or_url(challenge_id, params)
    self.class.http_post "participants/#{member.name}/#{challenge_id}/submission_url_file", params
  end

  # temp till we move to new submissions
  def current_submissions(challenge_id)
    self.class.http_get "participants/#{member.name}/#{challenge_id}/current_submssions"
  end

  # temp till we move to new submissions
  def delete_submission(challenge_id, submission_id)
    self.class.http_get "participants/#{member.name}/#{challenge_id}/delete_submission_url_file?submission_id=#{submission_id}"
  end  

  def submission_deliverables
    #self.class.raw_get_has_many([to_param, 'submissions']).map {|submission| Submission.new(submission)}
    self.class.http_get("participants/#{member.name}/#{challenge.challenge_id}/deliverables").map {|submission| SubmissionDeliverable.new(submission)}
  end

  # temp till we move to new submissions
  def find_submission(challenge_id, membername, submission_id)
    self.class.http_get "participants/#{membername}/#{challenge_id}/submission/#{submission_id}"
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
