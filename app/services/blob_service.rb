class BlobService
  def initialize(storage_service = nil)
    @storage_service = storage_service || Storage::StorageFactory.create_storage
    @validator = BlobValidator.default_validator
  end

  # Create a new blob
  def create(blob_id, content)
    # Validate content
    unless @validator.validate(blob_id, content)
      return ServiceResponse.error(
        message: I18n.t('blobs.errors.invalid_content'), 
        details: @validator.errors,
        status: :unprocessable_entity,
        error_code: 'blobs.invalid_content'
      )
    end

      if Blob.exists?(blob_id: blob_id)
       return ServiceResponse.error(
        message: I18n.t('blobs.errors.already_exists'),
        status: :unprocessable_entity,
        error_code: 'blobs.already_exists'
    )
    end

    # Store the blob content
    begin
      # Store the blob using the configured storage backend
      metadata = @storage_service.store(blob_id, content)
      
      # Create the blob record
      blob = Blob.create!(
        blob_id: blob_id,
        size: metadata[:size],
        storage_provider: metadata[:storage_provider],
        reference_path: metadata[:reference_path]
      )
      
      ServiceResponse.success(
        message: I18n.t('blobs.success.created'),
        data: { id: blob.blob_id, data: blob.content ,size: blob.size ,created_at: blob.created_at },
        status: :created
      )
    rescue => e
      Rails.logger.error("Error creating blob: #{e.message}")
      ServiceResponse.error(
        message: I18n.t('blobs.errors.failed_to_create'), 
        details: e.message,
        status: :internal_server_error,
        error_code: 'blobs.failed_to_create'
      )
    end
  end

  # Retrieve a blob
  def find(blob_id)
    blob = Blob.find_by(blob_id: blob_id)
    
    if blob
      # Get the appropriate storage service based on where the blob was originally stored
      storage_service = get_storage_for_blob(blob)
      
      # Get the content from the appropriate storage backend
      content = storage_service.retrieve(blob_id)
      
      if content.nil?
        return ServiceResponse.error(
          message: I18n.t('blobs.errors.content_not_found'), 
          status: :not_found,
          error_code: 'blobs.content_not_found'
        )
      end
      
      # Add the content to the blob object
      blob.content = content
      
      ServiceResponse.success(
        message: I18n.t('blobs.success.retrieved'),
        data: { id: blob.blob_id, data: blob.content ,size: blob.size ,created_at: blob.created_at},
        status: :ok
      )
    else
      ServiceResponse.error(
        message: I18n.t('blobs.errors.not_found'), 
        status: :not_found,
        error_code: 'blobs.not_found'
      )
    end
  end

  private

  # Get the appropriate storage service for a blob based on its storage_provider
  def get_storage_for_blob(blob)
    # If storage_provider is nil or empty, use the default
    return @storage_service if blob.storage_provider.blank?
    
    # Otherwise create a storage service based on the provider
    Storage::StorageFactory.create_storage_by_name(blob.storage_provider)
  rescue => e
    Rails.logger.error("Error creating storage for blob #{blob.blob_id}: #{e.message}. Using default storage.")
    @storage_service
  end
end
