class ChallengesController < ApplicationController

  before_filter :set_nav_tick

  # list of challenges including open/closed status & pagination
  def index
    @challenges = Challenge.open
  end

  def show
    @challenge = Challenge.find params[:id]
    render :json => @challenge
  end

  # rss feed based upon the selected platform, technology & category
  def feed

  end 

  private

    def set_nav_tick
      @challenges_tick = true
    end

end
