module Api
  module V1
    class TokensController < ApplicationController
      skip_before_action :authenticate_request, only: [:create]
      
      # POST /api/v1/tokens
      # Create a new JWT token
      def create
        # Check if username/password is valid (simple implementation for demonstration)
        if valid_credentials?
          # Generate a JWT token with custom claims
          token_payload = {
            user_id: params[:username],
            scope: params[:scope] || 'default',  # Optional scope parameter
            client_info: request.user_agent      # Store client information
          }
          
          # Generate token
          token = TokenService.generate(token_payload)
          
          # Decode to get full payload for response
          decoded_payload = TokenService.decode(token)
          
          # Save the token to the auth_tokens table with descriptive information
          description = "API token for #{params[:username]} (#{params[:scope] || 'default'} scope)"
          auth_token = TokenService.save_token(token, description)
          
          # Return a simplified token response
          render json: {
            success: true,
            message: I18n.t('tokens.success.generated'),
            token: token
          }, status: :created
        else
          # Return simple error response
          render json: {
            success: false,
            message: I18n.t('tokens.errors.invalid_credentials')
          }, status: :unauthorized
        end
      end
      
      private
      
      # Simple implementation for validating credentials
      # In a real application, you would check against a users table
      def valid_credentials?
        # For demo purposes, accept any username with password 'password'
        # In a real application, you would use a proper authentication system
        params[:username].present? && params[:password] == 'password'
      end
    end
  end
end
