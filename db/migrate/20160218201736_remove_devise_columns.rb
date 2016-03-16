class RemoveDeviseColumns < ActiveRecord::Migration
  def change
    # Remove Devise Indices.
    remove_index :users, :email
    remove_index :users, :reset_password_token

    # Remove Devise DBAuth Columns
    remove_column :users, :guest, :boolean, default: false
    remove_column :users, :encrypted_password, :string, null: false, default: ''

    # Remove Devise Recoverable Columns
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime

    # Remove Devise Rememberable Columns
    remove_column :users, :remember_created_at, :datetime

    # Require Omniauth/CAS Columns.
    change_column_null :users, :uid, false
    change_column_null :users, :provider, false

    # Index Omniauth/CAS Columns.
    add_index :users, :uid
    add_index :users, :provider
  end
end
