class Search::Search
  include ActiveModel::Model
  attr_accessor :max_total_prize_money, :min_total_prize_money,
                :min_registered_members, :max_registered_members

  def self.attr_accessor(*vars)
    @column_names ||= []
    @column_names.concat( vars )
    super
  end

  def self.persisted?
    true
  end

end