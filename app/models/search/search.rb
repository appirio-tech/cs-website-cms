class Search::Search
  include ActiveModel::Model
  attr_accessor :max_top_prize, :min_top_prize

  def self.attr_accessor(*vars)
    @column_names ||= []
    @column_names.concat( vars )
    super
  end

end