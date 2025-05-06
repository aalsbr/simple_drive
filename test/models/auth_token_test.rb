require "test_helper"

class AuthTokenTest < ActiveSupport::TestCase
  test "should be valid with token and description" do
    auth_token = AuthToken.new(token: 'valid-token-123', description: 'Test token')
    assert auth_token.valid?
  end
  
  test "should require token" do
    auth_token = AuthToken.new(description: 'Test token')
    assert_not auth_token.valid?
    assert_includes auth_token.errors[:token], "can't be blank"
  end
  
  test "should validate presence of description" do
    auth_token = AuthToken.new(token: 'valid-token-123')
    assert_not auth_token.valid?
    assert_includes auth_token.errors[:description], "can't be blank"
  end
  
  test "should handle very long tokens" do
    # Create a very long token (simulating JWT)
    long_token = 'header.' + 'a' * 500 + '.signature'
    
    # Create an auth token with a long token
    auth_token = AuthToken.new(token: long_token, description: 'Long token test')
    
    # It should be valid
    assert auth_token.valid?
    
    # Save it and ensure it persists correctly
    assert auth_token.save
    
    # Reload from database and check token is intact
    reloaded = AuthToken.find(auth_token.id)
    assert_equal long_token, reloaded.token
  end
end
