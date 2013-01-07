require "csv"

namespace :leaderboard do
  desc "inserts test data to redis for leaderboard"
  task :add_test_data => :environment do
    filename = Rails.root.join("spec/fixtures/scores.csv")
    data = CSV.read(filename)
    data.map do |row|
      next if row.first == "challenge"

      attrs = {
        challenge_id: row[0],
        username: row[1],
        prize: row[2],
        categories: row[3],
        date: row[4],
        community: (row[5].present? ? row[5] : nil)
      }
      Leaderboard::Score.new(attrs).save
      unless Leaderboard::Member.find_by_name(row[1])
        attrs = {
          name: row[1],
          picture: "facebook_32.png"
        }
        Leaderboard::Member.new(attrs).save
      end
    end
  end

  desc "clears leaderboard from redis"
  task :clear => :environment do
    Leaderboard.clear_redis
  end

end
