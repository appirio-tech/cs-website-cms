class CreateCodeUploads < ActiveRecord::Migration
  def change
    create_table :code_uploads do |t|
      t.string :code

      t.timestamps
    end
  end
end
