class Search::Category < Ohm::Model
  attribute :display_name
  index :display_name
  reference :challenge, Search::Challenge
end