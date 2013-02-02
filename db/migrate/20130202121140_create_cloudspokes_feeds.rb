class CreateCloudspokesFeeds < ActiveRecord::Migration
  def change
    create_table :cloudspokes_feeds do |t|
      t.string :name
      t.text :summary
      t.string :url
      t.string :entry_type
      t.datetime :published_at
      t.string :guid

      t.timestamps
    end
  end
end
