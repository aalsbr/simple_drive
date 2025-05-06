class HealthController < ApplicationController
  # Skip authentication for health check
  skip_before_action :authenticate_request
  
  def index
    render json: { status: 'ok', timestamp: Time.now.utc }
  end
end
