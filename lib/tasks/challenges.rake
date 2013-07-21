namespace :challenges do
  desc "clears leaderboard from redis"
  task :redis_sync_all => :environment do
    Challenge.redis_sync_all
  end

  desc "zips all the submissions for a challenge and notify with the url of zipfile"
  task :zip_submissions, [:challenge_id, :email] => :environment do |t, args|
    Resque.enqueue(SubmissionZipper, args.challenge_id, args.email)
  end

  desc "removes the zipfile created with challenges:zip_submissions rake task"
  task :remove_zip_submissions, [:challenge_id] => :environment do |t, args|
    SubmissionZipper.clear(args.challenge_id.split(":"))
  end

end
