class Search::Challenge < Ohm::Model
  include Ohm::Callbacks

  attribute :cid
  index :cid

  attribute :name
  index :name

  attribute :end_date
  index :end_date

  attribute :registered_members
  index :registered_members

  attribute :top_prize
  index :top_prize

  attribute :is_open
  index :is_open

  attribute :description

  collection :categories, Search::Category

  def self.between(range, attribute)
    range_by_score(attribute, range.first, range.last)
  end

  def self.filter(search)
    #by_registered = range_by_score :registered_members, search.min_registered_members, search.max_registered_members
    by_prize = range_by_score :top_prize, search.min_top_prize, search.max_top_prize
    #(by_registered & by_prize).map(&Search::Challenge)
    by_prize.map(&Search::Challenge)
  end

  def parse(hash)
    self.name = hash["Name"]
    self.end_date = Time.parse(hash["End_Date__c"]).to_i
    self.registered_members = hash["Registered_Members__c"].to_i
    self.top_prize = hash["Top_Prize__c"].delete('$').to_i
    self.is_open = hash["Is_Open__c"].to_b
    self.description = hash["Description__c"]
    self.cid = hash["ID__c"].to_i
    self
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
    self.class.key[:end_dates].zadd(end_date, id)
    self.class.key[:top_prize].zadd(top_prize, id)
    self.class.key[:registered_members].zadd(registered_members, id)
  end

  # make sure the filter keys are removed
  # In this case we use the raw *Redis* command
  # [ZREM](http://redis.io/commands/zrem).
  def after_delete
    self.class.key[:end_dates].zrem(id)
    self.class.key[:top_prize].zrem(id)
    self.class.key[:registered_members].zrem(id)
  end

  def self.range_by_score(_key, beginning = '-inf', ending = '+inf')
    beginning ||= '-inf'
    ending ||= '+inf'
    key[_key.to_sym].zrangebyscore(beginning, ending)
  end

end