class ChallengesController < ApplicationController

  def closed
    # @challenges = Challenge.closed
    # render :json => @challenges
  end

  def recent
    @challenges = Challenge.recent
    render :json => @challenges
  end

  def comments
  end

  def registrants
    @participants = Challenge.find params[:id].participantsrender :json => @challenges
    render :json => @participants
  end

  def survey
  end

  def index
    @challenges = Challenge.all params[:filters], params[:page]
  end

  def search
    @challenges = Challenge.search params[:search]
    render :json => @challenges
  end  

  def show
    @challenge = Challenge.find params[:id]
    render :json => @challenge
  end

  def update
  end
end
