require 'will_paginate/array'

class MembersController < ApplicationController  

  def community
    @community_tick = true
    @open_challenges = Challenge.open
    @featured_challenge =  Challenge.find @platform_stats['featured_challenge_id']
    @leaderboard = CsPlatform.leaderboard(current_access_token, :category => nil, :limit => 1000)
    @news_feed_items = CloudspokesFeed.where(:entry_type => 'news').order('published_at desc').limit(3)
    @post_feed_items = CloudspokesFeed.where(:entry_type => 'posts').order('published_at desc').limit(3)    
  end   

  def leaderboard
    @leaderboard_tick = true
    @this_month = CsPlatform.leaderboard(current_access_token, :period => 'month', :category => params[:category] || nil, :limit => 1000)
    @this_year = CsPlatform.leaderboard(current_access_token, :period => 'year', :category => params[:category] || nil, :limit => 1000)
    @all_time = CsPlatform.leaderboard(current_access_token, :category => params[:category] || nil, :limit => 1000)

    @this_month = @this_month.paginate(:page => params[:page_this_month] || 1, :per_page => 15) 
    @this_year = @this_year.paginate(:page => params[:page_this_year] || 1, :per_page => 15) 
    @all_time = @all_time.paginate(:page => params[:page_all_time] || 1, :per_page => 15) 
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
  end

  def show
    @member = Member.find(params[:id], { fields: 'id,name,profile_pic,quote,country,total_points,total_public_money,challenges_entered,valid_submissions,total_wins,total_1st_place,total_2nd_place,total_3st_place,percent_submitted,badgeville_id,website,facebook,github,linkedin,twitter' })
    @active_challenges = @member.active_challenges
    @past_challenges = @member.past_challenges
  end

  def past_challenges
    @past_challenges = Member.find(params[:id]).past_challenges 
  end  

  def update
  end
end
