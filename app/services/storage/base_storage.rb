# Base storage interface that all storage backends must implement
require_relative 'storage_error'

module Storage
  class BaseStorage
    # Store a blob with the given id and content
    # @param blob_id [String] unique identifier for the blob
    # @param content [String] base64 encoded content to store
    # @return [Hash] metadata about the stored blob
    # @raise [Storage::StorageError] on failure with sanitized error information
    def store(blob_id, content)
      raise NotImplementedError, "#{self.class.name}#store must be implemented"
    end

    # Retrieve a blob by its id
    # @param blob_id [String] unique identifier for the blob
    # @return [String] base64 encoded content of the blob
    # @raise [Storage::StorageError] on failure with sanitized error information
    def retrieve(blob_id)
      raise NotImplementedError, "#{self.class.name}#retrieve must be implemented"
    end

    protected
    
    # Safely handle errors by converting them to StorageError objects
    # @param error_code [String] an error code from Storage::ErrorCodes
    # @param public_message [String] a safe message that can be shown to users
    # @param original_error [Exception] the original error that occurred
    # @raise [Storage::StorageError] a sanitized error with sensitive info removed
    def handle_error(error_code, public_message, original_error = nil)
      raise StorageError.new(error_code, public_message, original_error)
    end
  end
end
