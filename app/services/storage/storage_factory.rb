module Storage
  class StorageFactory
    # Create a storage instance based on the configured backend
    def self.create_storage
      backend = ENV['STORAGE_BACKEND'] || 'file'
      
      case backend.downcase
      when 'file'
        FileStorage.new
      when 'database', 'db'
        DbStorage.new
      when 's3'
        S3Storage.new
      when 'ftp'
        FTPStorage.new
      else
        # Default to file storage if the backend is not recognized
        Rails.logger.warn "Unknown storage backend '#{backend}', defaulting to file storage"
        FileStorage.new
      end
    end
  end
end
