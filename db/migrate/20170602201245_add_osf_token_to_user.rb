class AddOsfTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :osf_token, :text
  end
end
