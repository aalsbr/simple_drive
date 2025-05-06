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
        status: :unprocessable_entity
      )
    end

      if Blob.exists?(blob_id: blob_id)
       return ServiceResponse.error(
        message: I18n.t('blobs.errors.already_exists'),
        status: :unprocessable_entity
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
        status: :internal_server_error
      )
    end
  end

  # Retrieve a blob
  def find(blob_id)
    blob = Blob.find_by(blob_id: blob_id)
    
    if blob
      # Get the content from the storage backend
      content = @storage_service.retrieve(blob_id)
      
      if content.nil?
        return ServiceResponse.error(
          message: I18n.t('blobs.errors.content_not_found'), 
          status: :not_found
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
        status: :not_found
      )
    end
  end
end
