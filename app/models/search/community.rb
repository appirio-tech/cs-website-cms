class Search::Community < Ohm::Model
  attribute :name
  index :name
  reference :challenge, Search::Challenge
end