class SubmissionsController < ApplicationController
  before_filter :authenticate_user!

=begin

    get the current user's participant record using the API
      participant = Participant.find_by_member(params[:challenge_id], current_user.username)
    get the deliverables (files, url, etc) that they have already submitted
      deliverables = participant.submission_deliverables

    you can update the participant's submission detail info:
      participant.submission_overview = 'this is why my code is <b>awesome</b>'
      participant.apis = 'google;google app engine'
      participant.paas = 'heroku'
      participant.languages = 'JavaScript:ruby'
      participant.technologies = 'node.js;faye'
      participant.update        

    to create a new deliverable (url after uplaoding a file):
      deliverable = SubmissionDeliverable.new
      deliverable.type = 'Code'
      deliverable.comments = 'This file contains awesome code!'
      deliverable.url = 'http://www.dropbox.com/test.zip'
      deliverable.hosting_platform = 'Salesforce.com;Heroku'
      deliverable.language = 'Ruby'
      # create the new deliverables record
      results = participant.create_deliverable(params[:challenge_id], current_user.username, deliverable) 

    to update a deliverable:
      participant = Participant.find_by_member(params[:challenge_id], current_user.username)
      deliverable = participant.submission_deliverables.first
      deliverable.comments = 'these are my updated comments'
      deliverable.deleted = true # pass deleted==true to delete the deliverable
      results = participant.update_deliverable(params[:challenge_id], current_user.username, deliverable)     

=end

  def show
    @deliverables = submission.deliverables # old code from redis
  end

  def update
    submission.update(params[:submission]) 

    respond_to do |format|
      format.html {redirect_to challenge_submission_path(challenge)}
      format.js
    end
  end

  private

    def challenge
      @challenge ||= Challenge.find params[:challenge_id]
    end

    # coming from redis?
    def submission
      @submission ||= challenge.submission_of(current_user)
    end

end
