class Requirement < ActiveRecord::Base
  attr_accessible :active, :challenge_id, :description, :library, :order_by, :scoring_type, :section, :weight
end
