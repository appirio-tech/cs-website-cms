namespace :challenges do
  desc "clears leaderboard from redis"
  task :redis_sync_all => :environment do
    Challenge.redis_sync_all
  end
end
