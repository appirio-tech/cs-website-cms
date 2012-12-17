class Search::Challenge < Ohm::Model
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

  collection :categories, :'Search::Category'

  def self.between(range, attribute)
    set = self.find(attribute.to_sym => range.first)
    range.each do |i|
      set = set.union(attribute.to_sym => i)
    end
    set
  end

  def self.filter(search)
    by_registered = self.between(self.max_registered_members..search.min_registered_members, :registered_members)
    by_prize = all.sort_by(:top_prize).to_a.reject {|e| e.top_prize.to_i < search.min_top_prize.to_i || e.top_prize.to_i > search.max_top_prize.to_i}
    by_registered & by_prize
  end

  def parse(hash)
    self.name = hash["Name"]
    self.end_date = Date.parse(hash["End_Date__c"])
    self.registered_members = hash["Registered_Members__c"].to_i
    self.top_prize = hash["Top_Prize__c"]
    self.is_open = hash["Is_Open__c"].to_b
    self.description = hash["Description__c"]
    self.cid = hash["ID__c"].to_i
    self
  end

  def self.parse(hash)
    new.parse(hash)
  end

end