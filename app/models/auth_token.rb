class AuthToken < ApplicationRecord
  # Generate a secure random token if none provided
  before_validation :generate_token, on: :create, if: -> { token.blank? }
  
  # Validations
  validates :token, presence: true, uniqueness: true
  validates :description, presence: true
  
  private
  
  def generate_token
    # Generate a secure random token (32 bytes, Base64 encoded)
    self.token = SecureRandom.base64(32)
  end
end
