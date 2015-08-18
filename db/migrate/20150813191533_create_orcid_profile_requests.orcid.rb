# This migration comes from orcid (originally 20140205185338)
class CreateOrcidProfileRequests < ActiveRecord::Migration
  def change
    create_table :orcid_profile_requests do |t|
      t.integer :user_id, unique: true, index: true, null: false
      t.string :given_names, null: false
      t.string :family_name, null: false
      t.string :primary_email, null: false
      t.string :orcid_profile_id, unique: true, index: true
      t.timestamps
    end
  end
end
