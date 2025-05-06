require 'test_helper'

module Api
  module V1
    class TokensControllerTest < ActionDispatch::IntegrationTest
      setup do
        # Set up test environment
        ENV['JWT_SECRET'] = 'test-jwt-secret-for-controller-tests'
      end
      
      teardown do
        # Clean up
        ENV.delete('JWT_SECRET')
      end
      
      test "should generate token with valid credentials" do
        # Make request to token endpoint with valid credentials
        post api_v1_tokens_path, params: { 
          username: 'testuser', 
          password: 'password' 
        }, as: :json
        
        # Assert response
        assert_response :created
        assert_equal true, json_response['success']
        assert_equal I18n.t('tokens.success.generated'), json_response['message']
        assert_not_nil json_response['token']
      end
      
      test "should return error with invalid credentials" do
        # Make request with invalid password
        post api_v1_tokens_path, params: {
          username: 'testuser', 
          password: 'wrong_password'
        }, as: :json
        
        # Assert response
        assert_response :unauthorized
        assert_equal false, json_response['success']
        assert_equal I18n.t('tokens.errors.invalid_credentials'), json_response['message']
      end
      
      test "should include optional scope in generated token" do
        # Make request with scope parameter
        post api_v1_tokens_path, params: {
          username: 'testuser', 
          password: 'password',
          scope: 'read:files'
        }, as: :json
        
        # Get the token and decode it to verify scope
        assert_response :created
        token = json_response['token']
        decoded = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: 'HS256' })[0]
        
        # Verify scope was included
        assert_equal 'read:files', decoded['scope']
      end
      
      private
      
      def json_response
        @json_response ||= JSON.parse(response.body)
      end
    end
  end
end
