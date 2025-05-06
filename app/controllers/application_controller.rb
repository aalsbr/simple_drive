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
      return render json: { error: I18n.t('auth.errors.unauthorized') }, status: :unauthorized
    end
    
    # Extract the token from the header
    token = auth_header.gsub('Bearer ', '')
    
    # Verify the JWT token
    decoded_payload = TokenService.decode(token)
    
    # If token invalid or expired, return 401 Unauthorized
    unless decoded_payload
      return render json: { error: I18n.t('auth.errors.unauthorized_details') }, status: :unauthorized
    end
    
    # Lookup the token in the database for additional validation
    auth_token = TokenService.find_token(token)
    
    # If token not found in database, return 401 Unauthorized
    unless auth_token
      return render json: { error: I18n.t('auth.errors.unauthorized') }, status: :unauthorized
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
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
