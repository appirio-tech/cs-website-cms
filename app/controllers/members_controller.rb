require 'will_paginate/array'

class MembersController < ApplicationController  

  def community
    @community_tick = true
    @open_challenges = Challenge.open
    @featured_challenge =  featured_challenge @platform_stats['featured_challenge_id']
    @leaderboard = CsPlatform.leaderboard_alltime(guest_access_token, :category => nil, :limit => 1000)
    @news_feed_items = CloudspokesFeed.where(:entry_type => 'news').order('published_at desc').limit(3)
    @post_feed_items = CloudspokesFeed.where(:entry_type => 'posts').order('published_at desc').limit(3)    
  end   

  def leaderboard
    @leaderboard_tick = true
    @this_month = CsPlatform.leaderboard_month(guest_access_token, :period => 'month', :category => params[:category] || nil, :limit => 1000)
    @this_year = CsPlatform.leaderboard_year(guest_access_token, :period => 'year', :category => params[:category] || nil, :limit => 1000)
    @all_time = CsPlatform.leaderboard_alltime(guest_access_token, :category => params[:category] || nil, :limit => 1000)

    @this_month = @this_month.paginate(:page => params[:page_this_month] || 1, :per_page => 15) 
    @this_year = @this_year.paginate(:page => params[:page_this_year] || 1, :per_page => 15) 
    @all_time = @all_time.paginate(:page => params[:page_all_time] || 1, :per_page => 15) 
  end

  def show
    @member = Member.find(params[:id], { fields: 'id,name,profile_pic,quote,country,total_points,total_public_money,challenges_entered,valid_submissions,total_wins,total_1st_place,total_2nd_place,total_3st_place,percent_submitted,badgeville_id,website,facebook,github,linkedin,twitter' })
    @active_challenges = @member.active_challenges
    @past_challenges = @member.past_challenges
  end

  def past_challenges
    @past_challenges = Member.find(params[:id]).past_challenges 
  end  

  private

    def featured_challenge(challenge_id)
      Rails.cache.fetch('featured-challenge', :expires_in => ENV['MEMCACHE_EXPIRY'].to_i.minute) do
        Challenge.find challenge_id
      end
    end   

end
