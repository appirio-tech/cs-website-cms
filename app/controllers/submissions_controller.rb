class SubmissionsController < ApplicationController
  before_filter :authenticate_user!

  def show
    #@deliverables = submission.deliverables
    participant = Participant.find_by_member(params[:challenge_id], current_user.username)
    # current submissions from sfdc -- returns a collection of SubmissionDeliverables
    render :json => participant.submission_deliverables
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

    def submission
      @submission ||= challenge.submission_of(current_user)
    end

end
