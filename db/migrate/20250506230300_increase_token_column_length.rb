class IncreaseTokenColumnLength < ActiveRecord::Migration[7.1]
  def up
    # First remove the index
    remove_index :auth_tokens, :token
    
    # Then change the column length
    change_column :auth_tokens, :token, :string, limit: 1024
    
    # Add a prefix index (using first 255 characters)
    add_index :auth_tokens, :token, name: "index_auth_tokens_on_token", length: 255
  end
  
  def down
    # Remove the index
    remove_index :auth_tokens, :token
    
    # Change the column back to default size
    change_column :auth_tokens, :token, :string
    
    # Add back the original index
    add_index :auth_tokens, :token, name: "index_auth_tokens_on_token", unique: true
  end
end
