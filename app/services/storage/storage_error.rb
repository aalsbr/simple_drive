module Storage
  # Custom error class for storage services that handles sensitive information securely
  class StorageError < StandardError
    attr_reader :error_code, :public_message
    
    # List of patterns to sanitize from error messages
    SENSITIVE_PATTERNS = [
      /password=[^&\s]*/i,         # Passwords in URLs or parameters
      /key=[^&\s]*/i,             # API keys
      /secret=[^&\s]*/i,          # Secret keys
      /token=[^&\s]*/i,           # Tokens
      /auth[^&\s]*/i,             # Auth related data
      /basic\s+[a-zA-Z0-9+\/=]+/i, # Basic auth headers
      /bearer\s+[a-zA-Z0-9._\-]+/i, # Bearer tokens
      /[\w\.\-]+@[\w\.\-]+/      # Email addresses
    ]
    
    # Initialize with a descriptive code, public-safe message, and original error
    def initialize(error_code, public_message, original_error = nil)
      @error_code = error_code
      @public_message = public_message
      @original_error = original_error
      
      # Keep only the public message for user-facing errors
      full_message = public_message
      
      # Pass the sanitized message to the parent class
      super(sanitize_message(full_message))
      
      # Log the original error with sanitized message
      if original_error && defined?(Rails.logger)
        Rails.logger.error("Storage Error [#{error_code}]: #{sanitize_message(original_error.message)}")
        Rails.logger.error(original_error.backtrace.join("\n")) if original_error.backtrace
      end
    end
    
    # Convert to a hash for API responses
    def to_hash
      {
        error: true,
        error_code: @error_code,
        message: @public_message
      }
    end
    
    private
    
    # Sanitize messages to avoid leaking sensitive information
    def sanitize_message(message)
      return "" unless message
      
      sanitized = message.to_s.dup
      
      # Replace sensitive patterns with [REDACTED]
      SENSITIVE_PATTERNS.each do |pattern|
        sanitized.gsub!(pattern, '[REDACTED]')
      end
      
      # Check for potential JSON or XML with credentials
      sanitized.gsub!(/"(password|secret|key|token|auth)"\s*:\s*"[^"]*"/i, '"\1":"[REDACTED]"')
      sanitized.gsub!(/<(password|secret|key|token|auth)>.*?<\/(password|secret|key|token|auth)>/i, '<\1>[REDACTED]</\2>')
      
      sanitized
    end
  end
  
  # Error codes for storage service errors
  module ErrorCodes
    # Authentication & Authorization errors
    UNAUTHORIZED = 'storage.unauthorized'
    FORBIDDEN = 'storage.forbidden'
    CREDENTIALS_MISSING = 'storage.credentials_missing'
    
    # Storage operation errors
    NOT_FOUND = 'storage.not_found'
    UPLOAD_FAILED = 'storage.upload_failed'
    DOWNLOAD_FAILED = 'storage.download_failed'
    DELETE_FAILED = 'storage.delete_failed'
    
    # Configuration errors
    CONFIGURATION_ERROR = 'storage.configuration_error'
    
    # Connection errors
    CONNECTION_ERROR = 'storage.connection_error'
    TIMEOUT = 'storage.timeout'
    
    # General errors
    UNKNOWN_ERROR = 'storage.unknown_error'
  end
end
