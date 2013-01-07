class Leaderboard::Score
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON
  self.include_root_in_json = false

  attr_accessor :challenge_id, :place, :prize, :date, :username, :community

  def initialize(json_or_hash)
    if json_or_hash.is_a?(String)
      from_json(json_or_hash)
    elsif json_or_hash.is_a?(Hash)
      self.attributes = json_or_hash
    end
  end

  def attributes
    {
      challenge_id: challenge_id,
      place: place,
      prize: prize,
      date: date,
      username: username,
      community: community,
      categories: categories
    }
  end

  def attributes=(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end    
  end


  def exist?
    REDIS.exists key
  end

  def save
    return false if exist?

    REDIS.multi do |multi|
      # save score
      multi.set key, to_json

      # save leaderboard
      lb_keys.each do |lb_key|
        multi.zincrby "#{lb_key}:prizes", prize, username
        multi.zincrby "#{lb_key}:wins", 1, username
      end
    end

    true
  end

  def delete
    REDIS.multi do |multi|
      multi.del key

      lb_keys.each do |lb_key|
        multi.zincrby "#{lb_key}:prizes", -prize, username
        multi.zincrby "#{lb_key}:wins", -1, username
      end
    end
  end


  def prize=(prize)
    @prize = prize.to_f
  end
  def date=(date)
    @date = Time.parse(date) rescue nil
  end
  def place=(place)
    @place = place.to_i
  end

  def categories=(categories)
    categories = categories.split(/,\s*/) if categories.is_a?(String)
    @categories = categories.to_a.map {|c| c.downcase.sub /\s/, ""}
  end
  def categories
    @categories ||= []
  end

  def community
    @community ||= "all"
  end


  private

  def lb_keys
    @lb_keys ||= begin
      (categories + ["all"]).inject([]) do |ret, cat|
        ret << "cs:leaderboard:#{community}:#{cat}:all:all"
        if date
          ret << "cs:leaderboard:#{community}:#{cat}:#{date.year}:all"
          ret << "cs:leaderboard:#{community}:#{cat}:#{date.year}:#{date.month}"
        end
        ret
      end
    end
  end

  def key
    @key ||= "cs:leaderboard:score:#{username}:#{challenge_id}"
  end
end
