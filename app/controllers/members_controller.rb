require 'will_paginate/array'

class MembersController < ApplicationController  

  before_filter :redirect_old_params

  def community
    @community_tick = true
    @open_challenges = Challenge.open
    @featured_challenge =  featured_challenge @platform_stats['featured_challenge_id']
    @leaderboard = CsPlatform.leaderboard_alltime(guest_access_token, :category => nil, :limit => 1000)
    @news_feed_items = CloudspokesFeed.where(:entry_type => 'news').order('published_at desc').limit(5)
    @post_feed_items = CloudspokesFeed.where(:entry_type => 'posts').order('published_at desc').limit(5)    
    respond_to do |format|
      format.html
      format.json { render :json => @platform_stats }
    end        
  end   

  def leaderboard
    @leaderboard_tick = true
    all_leaderboards = CsPlatform.leaderboard_all(guest_access_token, :limit => 1000)
    @this_month = all_leaderboards['this_month']
    @this_year = all_leaderboards['this_year']
    @all_time = all_leaderboards['all_time']

    @this_month = @this_month.paginate(:page => params[:page_this_month] || 1, :per_page => 15) 
    @this_year = @this_year.paginate(:page => params[:page_this_year] || 1, :per_page => 15) 
    @all_time = @all_time.paginate(:page => params[:page_all_time] || 1, :per_page => 15) 
    respond_to do |format|
      format.html
      format.json { 
        render :json => { :this_month => @this_month, 
          :this_year => @this_year, 
          :all_time => @all_time }
      }
    end     
  end

  def show
    @member = Member.find(params[:id], { fields: 'id,name,profile_pic,quote,country,total_points,total_public_money,challenges_entered,valid_submissions,total_wins,total_1st_place,total_2nd_place,total_3st_place,percent_submitted,badgeville_id,website,facebook,github,linkedin,twitter' })
    all_challenges = @member.all_challenges
    @active_challenges = @member.active_challenges(all_challenges)
    @past_challenges = @member.past_challenges(all_challenges)
  end

  def past_challenges
    member = Member.find(params[:id])
    all_challenges = member.all_challenges
    @past_challenges = member.past_challenges(all_challenges)
  end  

  private

    def featured_challenge(challenge_id)
      Rails.cache.fetch('featured-challenge', :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do
        Challenge.find challenge_id
      end
    end   

    def redirect_old_params
      if params.include?('page_all') || params.include?('page_month') || params.include?('page_year')
        redirect_to leaderboard_path
      end
    end

end
