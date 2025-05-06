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

# Generate a predictable token for development/testing purposes
if Rails.env.development? || Rails.env.test?
  token_value = 'test-token-1234567890'
  token_description = 'Development/Test token'
else
  # Use a secure random token in production
  token_value = SecureRandom.base64(32)
  token_description = 'Production seed token'
end

# Create or find the token (to avoid duplicates on multiple seed runs)
auth_token = AuthToken.find_or_create_by(token: token_value) do |token|
  token.description = token_description
end

# Output token information
puts "\n===== SEED TOKEN INFORMATION ====="
puts "Token: #{auth_token.token}"
puts "Description: #{auth_token.description}"
puts "=====================================\n"
