class LeaderboardsController < ApplicationController
  def index
    @all_time_leaders = Leaderboard.all_time params
    @for_year_leaders = Leaderboard.for_year params
    @for_month_leaders = Leaderboard.for_month params
  end

  def leaders
    @leaders = Leaderboard.leaders params
  end
end
