class AddSfdcColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_access_token_refresh_at, :datetime
    add_column :users, :mav_hash, :string
  end
end
