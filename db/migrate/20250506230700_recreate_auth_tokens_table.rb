class RecreateAuthTokensTable < ActiveRecord::Migration[7.1]
  def change
    # Drop the auth_tokens table
    drop_table :auth_tokens, if_exists: true
    
    # Recreate auth_tokens table with proper token column type
    create_table "auth_tokens" do |t|
      t.text "token", null: false, limit: 16.megabytes  # Use LONGTEXT in MySQL
      t.string "description"
      t.timestamps
    end
    
    # Add an index on the first 191 characters of the token (MySQL utf8mb4 limit)
    add_index :auth_tokens, :token, name: "index_auth_tokens_on_token", length: 191
  end
end
