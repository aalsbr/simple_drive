# Service for JWT token management
class TokenService
  class << self
    # Generate a JWT token
    # @param payload [Hash] token payload data
    # @param exp [Integer] expiration time in seconds from now (default: 24 hours)
    # @return [String] JWT token
    def generate(payload, exp = 24.hours.to_i)
      # Add standard JWT claims and API information
      current_time = Time.now.to_i
      
      # Merge standard claims and API information into payload
      payload = {
        # Standard JWT claims
        iss: 'simple_drive_api', # Issuer
        iat: current_time,       # Issued at time
        exp: current_time + exp, # Expiration time
        
        # API information
        api: {
          version: 'v1',
          name: 'SimpleDrive API',
          endpoint: '/api/v1'
        }
      }.merge(payload)
      
      # Generate JWT token
      JWT.encode(payload, jwt_secret, 'HS256')
    end
    
    # Decode and verify a JWT token
    # @param token [String] JWT token to decode
    # @return [Hash] decoded payload or nil if invalid
    def decode(token)
      # Decode the JWT token
      decoded = JWT.decode(token, jwt_secret, true, { algorithm: 'HS256' })
      decoded[0] # Return the payload
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
      Rails.logger.error("JWT decode error: #{e.message}")
      nil
    end
    
    # Save a token to the auth_tokens table
    # @param token [String] JWT token to save
    # @param description [String] description of the token
    # @return [AuthToken] created auth token record
    def save_token(token, description)
      AuthToken.create(token: token, description: description)
    end
    
    # Find a token in the auth_tokens table
    # @param token [String] JWT token to find
    # @return [AuthToken, nil] auth token record or nil if not found
    def find_token(token)
      AuthToken.find_by(token: token)
    end
    
    private
    
    # Get JWT secret key from environment variables
    # @return [String] JWT secret key
    def jwt_secret
      secret = ENV['JWT_SECRET']
      raise "JWT_SECRET environment variable is not set" unless secret.present?
      secret
    end
  end
end
