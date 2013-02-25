module Redis::ChallengeSearchable
  extend ActiveSupport::Concern

  included do |base|
  end

  module ClassMethods
    # Examples
    #   Challenge.search query: "ruby", state: "closed"
    #   Challenge.search categories: ["ruby", "java"]
    #   Challenge.search community: "Appirio"
    #   Challenge.search prize_money: {min: 1000, max: 3000}
    #   Challenge.search participants: {min: 2}
    #   Challenge.search participants: 3
    #   Challenge.search query: "ruby", sort_by: "prize_money", order: "DESC"
    #   Challenge.search query: "ruby", sort_by: "challenge_type"
    #
    # Returns array of challenges
    def search(options = {})
      # return all if options.blank?
      options ||= {}
      options.reject! {|k,v| v.blank?}
      options.reverse_merge(sort_by: "title", order: "asc")

      # searching
      set_key = redis_combined_set_by options.except(:sort_by, :order)
      return [] if set_key.blank?

      # sorting
      ids = redis_sorted_ids(set_key, options)
      return [] if ids.blank?

      # retrieving
      nest[:raw_data].hmget(*ids).map do |data|
        params = Hashie::Mash.new(JSON.parse(data))
        new params
      end
    end

    def nest
      @nest ||= Nest.new("search", REDIS)["challenge"]
    end

    def redis_sync_all

      ApiModel.access_token = User.admin_access_token

      challenges = all
      delete_ids = nest[:raw_data].hkeys - challenges.map(&:challenge_id)

      delete_ids.uniq.each {|cid| redis_remove(cid)}
      challenges.each {|c| c.redis_sync }
    end

    def redis_remove(cid)
      challenge = redis_find(cid)
      challenge.send(:redis_remove) if challenge
    end

    def redis_find(id)
      data = nest[:raw_data].hget id

      return nil if data.blank?

      new Hashie::Mash.new(JSON.parse(data))
    end

    def redis_all_category_names
      nest[:category_names].smembers || []
    end

    def redis_all_community_names
      nest[:community_names].smembers || []
    end


    private
    def redis_key_for_prize_money(value)
      if value.is_a?(Hash)
        min = value[:min].blank? ? 0 : value[:min].to_i
        max = value[:max].blank? ? 1000000 : value[:max].to_i
        nest[:temp][{prize_money: value}.hash].tap do |k|
          ids = nest[:prize_money].zrangebyscore(min, max)
          ids.each {|i| k.sadd(i)}
        end
      else
        nest[:prize_money][value]
      end
    end

    def redis_key_for_participants(value)
      if value.is_a?(Hash)
        min = value[:min].blank? ? 0 : value[:min].to_i
        max = value[:max].blank? ? 1000 : value[:max].to_i
        nest[:temp][{participants: value}.hash].tap do |k|
          ids = nest[:participants].zrangebyscore(min, max)
          ids.each {|i| k.sadd(i)}
        end
      else
        nest[:participants][value]
      end
    end

    def redis_key_for_community(name)
      nest[:community][name]
    end

    def redis_key_for_query(query)
      words = query.downcase.split.uniq
      metaphones = words.map {|w| Text::Metaphone.metaphone(w) }.compact.uniq

      keys = metaphones.map {|mp| nest[:metaphones][mp]}

      if keys.length > 1
        nest[:temp][{query: query}.hash].tap do |k|
          k.sunionstore *keys
        end
      else
        keys.first
      end
    end

    def redis_key_for_categories(categories)
      keys = categories.map {|cat| nest[:categories][cat]}.compact

      if keys.length > 1
        nest[:temp][{categories: categories}.hash].tap do |k|
          k.sunionstore *keys
        end
      else
        keys.first
      end
    end

    def redis_key_for_state(value)
      value == "open" ? nest[:open] : nest[:closed]
    end

    def redis_combined_set_by(options = {})
      sets = []

      options.each do |name, value|
        sets << send("redis_key_for_#{name}", value)
      end

      return nil if sets.empty?

      # combine sets
      if sets.size == 1
        sets.first
      else
        nest[:temp][options.hash].tap do |key|
          key.sinterstore *sets
        end
      end
    end

    def redis_sorted_ids(set_key, options = {})
      if options[:sort_by]
        sort_options = {}
        sort_options[:by] = nest[:sort][options[:sort_by]]['*']
        order = []
        order = ["ALPHA"] if %w(title end_date challenge_type).include? options[:sort_by]
        order << options[:order].upcase if options[:order]
        sort_options[:order] = order.join(" ") if order.present?
        p sort_options
        set_key.sort sort_options
      else
        set_key.smembers
      end
    end

  end

  def redis_sync
    if nest[:raw_data].hexists(challenge_id)
      redis_update
    else
      redis_insert
    end
  end

  def redis_update
    self.class.redis_remove(challenge_id)
    redis_insert
  end

  def redis_insert
    nest[:raw_data].hset challenge_id, raw_data.to_json

    redis_metaphones.each do |meta|
      nest[:metaphones][meta].sadd challenge_id
    end

    category_names.uniq.each do |cat|
      cat = cat.downcase
      nest[:categories][cat].sadd challenge_id
      nest[:category_names].sadd cat
    end

    open? ? nest[:open].sadd(challenge_id) : nest[:closed].sadd(challenge_id)

    nest[:prize_money].zadd(total_prize_money, challenge_id)
    nest[:prize_money][total_prize_money].sadd challenge_id

    nest[:participants].zadd(participants.count, challenge_id)
    nest[:participants][participants.count].sadd challenge_id

    if community_name.present?
      cname = community_name.downcase
      nest[:community][cname].sadd challenge_id
      nest[:community_names].sadd cname 
    end

    # for sort
    nest[:sort][:title][challenge_id].set name
    nest[:sort][:end_date][challenge_id].set end_date
    nest[:sort][:prize_money][challenge_id].set total_prize_money
    nest[:sort][:participants][challenge_id].set participants.count
    nest[:sort][:challenge_type][challenge_id].set challenge_type.downcase
  end



  private

  def redis_remove
    nest[:raw_data].hdel challenge_id
    redis_metaphones.each do |meta|
      nest[:metaphones][meta].srem challenge_id
    end
    category_names.uniq.each do |cat|
      nest[:categories][cat].srem challenge_id
    end

    open? ? nest[:open].srem(challenge_id) : nest[:closed].srem(challenge_id)

    nest[:prize_money].zrem challenge_id
    nest[:prize_money][total_prize_money].srem challenge_id

    nest[:participants].zrem challenge_id
    nest[:participants][participants.count].srem challenge_id

    nest[:community][community_name].srem challenge_id

    # for sort
    nest[:sort][:title][challenge_id].del name
    nest[:sort][:end_date][challenge_id].del end_date
    nest[:sort][:prize_money][challenge_id].del total_prize_money
    nest[:sort][:participants][challenge_id].del participants.count
    nest[:sort][:challenge_type][challenge_id].del challenge_type
  end

  def nest
    self.class.nest
  end

  IGNORES = ["the", "a", "an", "is", "are", "on", "at", "then", "for", "from", "at", "this", "that", "more"]
  def redis_keywords
    words = name.downcase.split.uniq + category_names - IGNORES
    words << community_name if community_name.present?
    words
  end

  def redis_metaphones
    redis_keywords.map {|w| Text::Metaphone.metaphone(w) }.compact.uniq
  end

end
