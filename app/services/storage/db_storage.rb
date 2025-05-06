require 'base64'

module Storage
  class DbStorage < BaseStorage
    # Store blob content in the database
    def store(blob_id, content)
      # Validation is now handled at the controller level
      # Just focus on storage operations
      
      # Decode to calculate size
      decoded_content = Base64.strict_decode64(content)
      
      # Create a new BlobBinaryStorage record for the actual content
      ActiveRecord::Base.transaction do
        # We'll store the actual content in a separate model to keep the Blob model lightweight
        blob_binary = BlobBinaryStorage.create!(blob_id: blob_id, content: content)
      end
      
      # Return metadata
      {
        blob_id: blob_id,
        size: decoded_content.bytesize,
        storage_provider: 'database',
        reference_path: nil  # Database storage doesn't need an external reference path
      }
    end

    def retrieve(blob_id)
      # Find the BlobBinaryStorage by blob_id
      blob_binary = BlobBinaryStorage.find_by(blob_id: blob_id)
      return nil unless blob_binary
      
      # Return the stored base64 content
      blob_binary.content
    end
  end
end
