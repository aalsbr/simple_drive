class RenameBlobContentTable < ActiveRecord::Migration[7.1]
  def change
    rename_table :blob_contents, :blob_binary_storage
  end
end
