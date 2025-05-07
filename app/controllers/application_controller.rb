class ApplicationController < ActionController::API
  # Exception handling
  rescue_from StandardError, with: :render_error
  
  # Authenticate all requests by default
  before_action :authenticate_request
  
  protected
  
  # Authentication method - call this with before_action in controllers that need authentication
  def authenticate_request
    # Extract the Authorization header
    auth_header = request.headers['Authorization']
    
    # If no Authorization header, return 401 Unauthorized
    unless auth_header && auth_header.start_with?('Bearer ')
      return render json: { 
        success: false, 
        message: I18n.t('auth.errors.unauthorized'),
        error_code: 'auth.unauthorized'
      }, status: :unauthorized
    end
    
    # Extract the token from the header
    token = auth_header.gsub('Bearer ', '')
    
    # Verify the JWT token
    decoded_payload = TokenService.decode(token)
    
    # If token invalid or expired, return 401 Unauthorized
    unless decoded_payload
      return render json: { 
        success: false, 
        message: I18n.t('auth.errors.unauthorized_details'),
        error_code: 'auth.invalid_token'
      }, status: :unauthorized
    end
    
    # Lookup the token in the database for additional validation
    auth_token = TokenService.find_token(token)
    
    # If token not found in database, return 401 Unauthorized
    unless auth_token
      return render json: { 
        success: false, 
        message: I18n.t('auth.errors.unauthorized'),
        error_code: 'auth.token_not_found'
      }, status: :unauthorized
    end
    
    # Store decoded payload for controller use
    @current_payload = decoded_payload
  end
  
  # Get the current token payload
  def current_payload
    @current_payload
  end
  
  private
  
  def render_error(exception)
    render json: { 
      success: false, 
      message: exception.message,
      error_code: 'system.unexpected_error'
    }, status: :unprocessable_entity
  end
end
