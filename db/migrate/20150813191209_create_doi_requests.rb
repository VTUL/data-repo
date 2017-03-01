class CreateDoiRequests < ActiveRecord::Migration
  def change
    create_table :doi_requests do |t|
      t.string "collection_id"
      t.string "ezid_doi", default: "doi:pending", null: false
      t.string "asset_type", default: "Collection", null: false
      t.boolean "completed", default: false
      t.timestamps null: false
    end

    add_index :doi_requests, :ezid_doi
    add_index :doi_requests, :collection_id
  end
end
