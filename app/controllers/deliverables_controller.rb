class DeliverablesController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @deliverable = submission.create_deliverable(params[:deliverable])

    respond_to do |format|
      format.html {redirect_to challenge_submission_path(challenge)}
      format.js
    end
  end

  def upload
    @deliverable = submission.upload_file(params[:file])  
    render json: @deliverable
  end

  def update
    deliverable.update(params[:deliverable])
    submission.save

    respond_to do |format|
      format.html {redirect_to challenge_submission_path(challenge)}
      format.js
    end
  end

  def destroy
    @deliverable = submission.destroy_deliverable(params[:id])

    respond_to do |format|
      format.html {redirect_to challenge_submission_path(challenge)}
      format.js
    end
  end

  private

    def deliverable
      @deliverable ||= submission.find_deliverable(params[:id])
    end

    def challenge
      @challenge ||= Challenge.find(params[:challenge_id])
    end

    def submission
      @submission ||= challenge.submission_of(current_user)
    end

end
