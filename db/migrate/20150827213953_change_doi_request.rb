class ChangeDoiRequest < ActiveRecord::Migration
  def change
    remove_column :doi_requests, :completed
    remove_index :doi_requests, column: :collection_id
    rename_column :doi_requests, :collection_id, :asset_id
    add_index :doi_requests, [:asset_id, :asset_type]
  end
end
