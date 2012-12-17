class Search::Challenge < Ohm::Model
  include Ohm::Callbacks

  attribute :challenge_id
  index :challenge_id

  attribute :challenge_type
  index :challenge_type

  attribute :name
  index :name

  attribute :start_date
  index :start_date

  attribute :end_date
  index :end_date

  attribute :registered_members
  index :registered_members

  attribute :total_prize_money
  index :total_prize_money

  attribute :is_open
  index :is_open

  attribute :description

  list :categories, Search::Category

  attribute :community
  index :community

  def self.between(range, attribute)
    range_by_score(attribute, range.first, range.last)
  end

  def self.filter(search)
    by_registered = range_by_score :registered_members, search.min_registered_members, search.max_registered_members
    by_prize = range_by_score :total_prize_money, search.min_total_prize_money, search.max_total_prize_money
    by_categories_query = Search::Category.find(display_name: nil)
    result = (by_registered & by_prize)
    unless search.categories.empty?
      search.categories.each do |cat|
        by_categories_query = by_categories_query.union(display_name: cat) unless cat.blank?
      end
      by_categories = by_categories_query.to_a.map(&:challenge).map(&:id).uniq
      result = result & by_categories
    end
    result.map(&Search::Challenge)
  end

  def parse(hash)
    challenge = Search::Challenge.find(challenge_id: hash["challenge_id"]).first || Search::Challenge.new
    challenge.name = hash["name"]
    challenge.end_date = Time.parse(hash["end_date"]).to_i
    challenge.registered_members = hash["registered_members"].to_i
    challenge.total_prize_money = hash["total_prize_money"]
    challenge.is_open = hash["is_open"].to_b
    challenge.description = hash["description"]
    challenge.challenge_id = hash["challenge_id"].to_i
    challenge.community = hash["community__r"]["name"] if hash["community__r"]
    challenge.save
    hash["challenge_categories__r"]["records"].each do |cat|
      display_name = cat["display_name"]
      Search::Category.create(display_name: display_name, challenge: challenge) unless challenge.categories.entries.include?({display_name: display_name})
    end
    challenge
  end

  def self.parse(hash)
    new.parse(hash)
  end

  def self.latest
    range_by_score(:end_dates).map(&Search::Challenge).reverse
  end

protected

  # add in filter params
  def after_save
    self.class.key[:end_date].zadd(end_date, id)
    self.class.key[:total_prize_money].zadd(total_prize_money, id)
    self.class.key[:registered_members].zadd(registered_members, id)
  end

  # make sure the filter keys are removed
  # In this case we use the raw *Redis* command
  # [ZREM](http://redis.io/commands/zrem).
  def after_delete
    self.class.key[:end_date].zrem(id)
    self.class.key[:total_prize_money].zrem(id)
    self.class.key[:registered_members].zrem(id)
  end

  def self.range_by_score(_key, beginning = '-inf', ending = '+inf')
    beginning ||= '-inf'
    ending ||= '+inf'
    key[_key.to_sym].zrangebyscore(beginning, ending)
  end

end