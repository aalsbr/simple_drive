class RemoveChecksumAddReferencePath < ActiveRecord::Migration[7.1]
  def change
    # Remove the checksum column from blobs table
    remove_column :blobs, :checksum, :string if column_exists?(:blobs, :checksum)
    
    # Add reference_path column to store storage-specific path references
    # This will store:
    # - File path for FileStorage backend
    # - S3 object reference for S3Storage backend
    # - NULL for DbStorage backend
    add_column :blobs, :reference_path, :string
  end
end
