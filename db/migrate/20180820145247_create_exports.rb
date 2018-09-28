class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.integer :user_id
      t.string :path
      t.string :download_id

      t.timestamps null: false
    end
  end
end
