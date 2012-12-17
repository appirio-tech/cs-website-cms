class Search::Search
  include ActiveModel::Model
  attr_accessor :max_registered_members, :min_registered_members,
                :max_top_prize, :min_top_prize
end