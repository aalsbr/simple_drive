require 'test_helper'

class TokenServiceTest < ActiveSupport::TestCase
  setup do
    # Set up a test JWT secret for consistency
    ENV['JWT_SECRET'] = 'test-jwt-secret-for-unit-tests'
  end
  
  teardown do
    # Clean up ENV changes
    ENV.delete('JWT_SECRET')
  end
  
  test "generates a valid JWT token" do
    payload = { user_id: 'testuser' }
    token = TokenService.generate(payload)
    
    # Assert token is a string and not empty
    assert_kind_of String, token
    assert_not_empty token
    
    # Verify token structure (format)
    assert_match(/^[\w-]*\.[\w-]*\.[\w-]*$/, token, "Token should be in JWT format")
  end
  
  test "decodes a valid token" do
    # Generate token with test payload
    test_payload = { user_id: 'testuser', test_claim: 'test-value' }
    token = TokenService.generate(test_payload)
    
    # Decode the token
    decoded = TokenService.decode(token)
    
    # Verify payload contents
    assert_equal 'testuser', decoded['user_id']
    assert_equal 'test-value', decoded['test_claim']
    assert decoded['exp'].present?, "Token should contain expiration time"
  end
  
  test "returns nil when decoding an invalid token" do
    # Test with invalid token
    assert_nil TokenService.decode('invalid.token.format')
  end
  
  test "returns nil when decoding an expired token" do
    # Generate token that expires immediately
    payload = { user_id: 'testuser' }
    token = TokenService.generate(payload, -10) # Expire 10 seconds in the past
    
    # Attempt to decode expired token
    assert_nil TokenService.decode(token)
  end
  
  test "saves token to database" do
    token = 'test-token-123'
    description = 'Test token description'
    
    assert_difference 'AuthToken.count', 1 do
      auth_token = TokenService.save_token(token, description)
      assert_equal token, auth_token.token
      assert_equal description, auth_token.description
    end
  end
  
  test "finds token in database" do
    # Create a token in the database
    token = 'find-this-token-123'
    AuthToken.create(token: token, description: 'Test token')
    
    # Find the token
    auth_token = TokenService.find_token(token)
    assert_not_nil auth_token
    assert_equal token, auth_token.token
  end
  
  test "returns nil when finding non-existent token" do
    assert_nil TokenService.find_token('non-existent-token')
  end
  
  test "token includes API information" do
    token = TokenService.generate({ user_id: 'testuser' })
    decoded = TokenService.decode(token)
    
    # Check API info is included
    assert decoded['api'].present?
    assert_equal 'v1', decoded['api']['version']
    assert_equal 'SimpleDrive API', decoded['api']['name']
    assert_equal '/api/v1', decoded['api']['endpoint']
  end
end
