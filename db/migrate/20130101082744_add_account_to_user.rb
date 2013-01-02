class AddAccountToUser < ActiveRecord::Migration
  def change
    add_column :users, :access_token, :string
    add_column :users, :sfdc_username, :string
    add_column :users, :profile_pic, :string
    add_column :users, :accountid, :string
  end
end
