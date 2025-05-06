class FixTokenColumnLength < ActiveRecord::Migration[7.1]
  def change
    # Just change the token column to TEXT type which can hold much larger strings
    change_column :auth_tokens, :token, :text
  end
end
