# Load storage backend classes
require_relative '../../app/services/storage/base_storage'
require_relative '../../app/services/storage/file_storage'
require_relative '../../app/services/storage/db_storage'
require_relative '../../app/clients/storage/s3_client'
require_relative '../../app/services/storage/s3_storage'
require_relative '../../app/clients/storage/ftp_client'
require_relative '../../app/services/storage/ftp_storage'

# Configure the storage backend based on environment variables
Rails.application.config.after_initialize do
  # Default to file storage if no backend is specified
  backend = ENV['STORAGE_BACKEND']&.downcase || 'file'
  
  # Initialize the appropriate storage backend
  case backend
  when 'file'
    Rails.configuration.storage_backend = Storage::FileStorage.new
  when 'database', 'db'
    Rails.configuration.storage_backend = Storage::DbStorage.new
  when 's3'
    # Ensure required S3 environment variables are present
    required_vars = ['S3_BUCKET_NAME', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY']
    missing_vars = required_vars.select { |var| ENV[var].blank? }
    
    if missing_vars.any?
      Rails.logger.warn "Missing required environment variables for S3 storage: #{missing_vars.join(', ')}"
      Rails.logger.warn "Falling back to file storage"
      Rails.configuration.storage_backend = Storage::FileStorage.new
    else
      # Initialize S3 storage with environment variables
      Rails.configuration.storage_backend = Storage::S3Storage.new
    end
  else
    Rails.logger.warn "Invalid storage backend: #{backend}. Falling back to file storage"
    Rails.configuration.storage_backend = Storage::FileStorage.new
  end
  
  # Log the configured storage backend
  Rails.logger.info "Configured storage backend: #{backend}"
end
