class Leaderboard::Member
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON
  self.include_root_in_json = false

  attr_accessor :name, :picture, :total_prizes, :rank, :total_wins

  class << self

    def find_by_name(name)
      json = REDIS.get(key(name))
      json ? new(json) : nil
    end

    def key(name)
      "cs:leaderboard:member:#{name}"
    end
  end

  def initialize(json_or_hash)
    if json_or_hash.is_a?(String)
      from_json(json_or_hash)
    elsif json_or_hash.is_a?(Hash)
      self.attributes = json_or_hash
    end
  end

  def attributes
    {
      name: name,
      picture: picture
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
    REDIS.set(key, to_json)
  end

  def delete
    REDIS.del key
  end


  private

  def key
    @key ||= self.class.key(name)
  end


end
