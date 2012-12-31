class Leaderboard
  class << self
    def update_scores(scores)
      scores.each do |score|
        score.save unless score.exist?
      end
    end

    def delete_scores(scores)
      scores.each do |score|
        score.delete unless score.exist?
      end
    end

    def clear_redis
      keys = REDIS.keys("cs:leaderboard:*")
      REDIS.del *keys if keys.present?
    end

    # Examples
    #   Leaderboard.leaders 
    #   Leaderboard.leaders community: "java"
    #   Leaderboard.leaders community: "java", category: "ruby"
    #   Leaderboard.leaders community: "java", category: "ruby", year: "2012", month: "10"
    #   Leaderboard.leaders category: "ruby", page: 2
    def leaders(options = {})
      community = options[:community] || "all"
      category = options[:category] || "all"
      year = options[:year] || "all"
      month = options[:month] || "all"
      key = "cs:leaderboard:#{community}:#{category}:#{year}:#{month}"

      get_leaders(key, options)
    end

    def all_time(options = {})
      leaders(options)
    end

    def for_year(options = {})
      leaders(options.merge(year: Time.zone.now.year))
    end

    def for_month(options = {})
      now = Time.zone.now
      leaders(options.merge(year: now.year, month: now.month))
    end


    private
    def get_leaders(key, options)
      page = options[:page] || 1
      start, stop = get_page_positions(page)
      usernames = REDIS.zrevrange("#{key}:prizes", start, stop)
      leaders = usernames.map do |uname|
        member = Leaderboard::Member.find_by_name(uname)
        member.total_prizes = REDIS.zscore("#{key}:prizes", uname).to_f
        member.total_wins = REDIS.zscore("#{key}:wins", uname).to_i
        member.rank = REDIS.zrevrank("#{key}:prizes", uname) + 1
        member
      end

      total = REDIS.zcard("#{key}:prizes")
      WillPaginate::Collection.create(page, per_page, total) do |pager|
        pager.replace(leaders)
      end
    end

    def per_page
      10
    end

    def get_page_positions(page = nil)
      page = (page || 1).to_i
      start = (page-1)*per_page
      stop = page*per_page - 1

      [start, stop]
    end
  end
end
