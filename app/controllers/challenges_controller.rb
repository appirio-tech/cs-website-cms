class ChallengesController < ApplicationController

  def closed
    @challenges = Challenge.closed(access_token)
  end

  def recent
    @challenges = Challenge.recent(access_token)
  end

  def comments
  end

  def registrants
    @participants = Challenge.find(access_token, params[:id]).participants
  end

  def survey
  end

  def index
    @challenges = Challenge.open(access_token)
  end

  def search
    @challenges = Challenge.search params[:search]
  end  

  def show
    @challenge = Challenge.find(access_token, params[:id])
  end

  def update
  end
end
