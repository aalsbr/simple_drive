# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a seed token for testing
# The token will be shown in the console output when running db:seed

# Generate a proper JWT token for development/testing purposes
require 'jwt'

jwt_secret = ENV['JWT_SECRET'] || 'development-jwt-secret-key'

if Rails.env.development? || Rails.env.test?
  # Create a predictable payload for testing
  payload = {
    sub: 'test-user-id',
    name: 'Test User',
    admin: true,
    iat: Time.now.to_i,
    exp: 30.days.from_now.to_i
  }
  token_description = 'Development/Test JWT token'
else
  # Create a more secure payload for production
  payload = {
    sub: SecureRandom.uuid,
    iat: Time.now.to_i,
    exp: 7.days.from_now.to_i
  }
  token_description = 'Production JWT token'
end

# Generate the JWT token
token_value = JWT.encode(payload, jwt_secret, 'HS256')

# Create or find the token (to avoid duplicates on multiple seed runs)
auth_token = AuthToken.find_or_create_by(description: token_description) do |token|
  token.token = token_value
end

# Output token information
puts "\n===== SEED TOKEN INFORMATION ====="
puts "Token: #{auth_token.token}"
puts "Description: #{auth_token.description}"
puts "=====================================\n"
