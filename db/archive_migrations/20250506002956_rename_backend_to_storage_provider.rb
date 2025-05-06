class RenameBackendToStorageProvider < ActiveRecord::Migration[7.1]
  def change
    rename_column :blobs, :backend, :storage_provider
  end
end
