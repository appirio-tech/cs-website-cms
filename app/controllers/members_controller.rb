class MembersController < ApplicationController

  def community
    @community_tick = true
    @stats = Platform.stats
    @open_challenges = Challenge.open
    @featured_challenge =  Challenge.find @stats['featured_challenge_id']
    @leaderboard = Platform.leaderboard
  end   

  def leaderboard
    @leaderboard_tick = true
  end

  def forums
    @forums_tick = true
  end  
  
  # note that we provide our own search service so that we have greater control
  # over the results; e.g. caching, endpoint configuration, result format, etc.
  def search
    @members = Member.search params[:keyword]
    render json: @members, :callback => params[:callback]
  end

  def challenges
  end

  def payments
  end

  def recommendations
  end

  def create_recommendations
  end

  def index
    @members = Member.all
    render :json => @members
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: @members }
    # end
  end

  def show
    @member = Member.find params[:id]
    render :json => @member
  end

  def update
  end
end
