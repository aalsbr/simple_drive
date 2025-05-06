require 'base64'
require 'fileutils'

module Storage
  class FileStorage < BaseStorage
    def initialize(storage_dir = nil)
      # Look for storage directory in this order:
      # 1. Explicitly provided directory (from constructor)
      # 2. Environment variable STORAGE_PATH
      # 3. Default to Rails.root.join('storage', 'blobs')
      @storage_dir = storage_dir || ENV['STORAGE_PATH'] || Rails.root.join('storage', 'blobs')
      
      # Ensure the directory exists
      FileUtils.mkdir_p(@storage_dir) unless Dir.exist?(@storage_dir)
      
      # Log the storage directory being used
      Rails.logger.info "FileStorage: Using directory: #{@storage_dir}"
    end

    def store(blob_id, content)
      # Validation is now handled at the controller level
      # Just focus on storage operations
      
      # Decode base64 content
      decoded_content = Base64.strict_decode64(content)
      file_path = File.join(@storage_dir, blob_id)
      
      # Write to file
      File.binwrite(file_path, decoded_content)
      
      # Return metadata
      {
        blob_id: blob_id,
        size: decoded_content.bytesize,
        storage_provider: 'file',
        reference_path: file_path
      }
    end

    def retrieve(blob_id)
      file_path = File.join(@storage_dir, blob_id)
      
      unless File.exist?(file_path)
        return nil
      end
      
      # Read file and encode to base64
      content = File.binread(file_path)
      Base64.strict_encode64(content)
    end
  end
end
