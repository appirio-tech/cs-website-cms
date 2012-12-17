class Search::Category < Ohm::Model
  extend ActiveModel::Naming
  attribute :display_name
  index :display_name
  reference :challenge, Search::Challenge
end