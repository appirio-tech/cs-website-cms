class CommunitiesController < ApplicationController
	before_filter :authenticate_user!

	def show
		@community = current_community
    # sort the leaders by position
		@community.leaderboard.sort! { |a,b| a['position'] <=> b['position'] }
	end

  def leaderboard
		@community = current_community
    # sort the leaders by position
		@community.leaderboard.sort! { |a,b| a['position'] <=> b['position'] }
		@points_leaderboard = @community.leaderboard
		@referral_leaderboard = CsPlatform.leaderboard_referral(guest_access_token)
  end

	private

	  def current_community
	  	@community ||= Community.find params[:id]
	  end  	

end
