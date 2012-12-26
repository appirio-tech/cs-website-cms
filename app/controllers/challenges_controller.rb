class ChallengesController < ApplicationController
  def closed
    @challenges = Challenge.closed
  end

  def recent
    @challenges = Challenge.closed
  end

  def comments
  end

  def registrants
    @participants = Challenge.find(params[:id]).participants
  end

  def survey
  end

  def index
    @challenges = Challenge.search params[:search]
  end

  def show
    @challenge = Challenge.find(params[:id])
  end

  def update
  end
end
