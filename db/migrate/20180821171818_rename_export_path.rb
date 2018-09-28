class RenameExportPath < ActiveRecord::Migration
  def change
    rename_column :exports, :path, :filename
  end
end
