class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.text :description
      t.string :section
      t.string :scoring_type
      t.integer :order_by
      t.float :weight
      t.string :challenge_id
      t.string :library
      t.boolean :active, :default => true
      t.timestamps
    end
  end
end
