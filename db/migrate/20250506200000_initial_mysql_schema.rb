class InitialMysqlSchema < ActiveRecord::Migration[7.1]
  def change
    # Auth tokens table
    create_table "auth_tokens" do |t|
      t.text "token", null: false, limit: 16.megabytes  # Use LONGTEXT in MySQL
      t.string "description"
      t.timestamps
      t.index ["token"], name: "index_auth_tokens_on_token", length: 191 # Limited index size for MySQL utf8mb4
    end

    # Blob binary storage table
    create_table "blob_binary_storages" do |t|
      t.string "blob_id", null: false
      t.text "content", limit: 4294967295  # Use LONGTEXT in MySQL
      t.timestamps
      t.index ["blob_id"], name: "index_blob_binary_storages_on_blob_id", unique: true
    end

    # Blobs metadata table
    create_table "blobs" do |t|
      t.string "blob_id", null: false
      t.integer "size"
      t.string "storage_provider"
      t.string "reference_path"
      t.timestamps
      t.index ["blob_id"], name: "index_blobs_on_blob_id", unique: true
    end
  end
end
