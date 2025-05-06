class ServiceResponse
  attr_reader :success, :message, :data, :details, :status

  def initialize(success:, message:, data: nil, details: nil, status: nil)
    @success = success
    @message = message
    @data = data
    @details = details
    @status = status || (success ? :ok : :bad_request)
  end

  def successful?
    @success
  end

  def to_hash
    result = {
      success: @success,
      message: @message
    }
    
    result[:data] = @data if @data.present?
    result[:details] = @details if @details.present?
    
    result
  end

  # Factory method for success responses
  def self.success(message:, data: nil, status: :ok)
    new(success: true, message: message, data: data, status: status)
  end

  # Factory method for error responses
  def self.error(message:, details: nil, status: :bad_request)
    new(success: false, message: message, details: details, status: status)
  end
end
