require 'base64'
require_relative '../../../app/clients/storage/ftp_client'

module Storage
  class FTPStorage < BaseStorage
    # Initialize the FTPStorage service
    # @param options [Hash] configuration options for FTP
    def initialize(options = {})
      @client = ::Clients::Storage::FTPClient.new(options)
    end

    # Store a blob with the given id and content
    # @param blob_id [String] unique identifier for the blob
    # @param content [String] base64 encoded content to store
    # @return [Hash] metadata about the stored blob
    # @raise [Storage::StorageError] on failure with sanitized error information
    def store(blob_id, content)
      begin
        decoded_content = Base64.strict_decode64(content)
        
        unless @client.put_object(blob_id, decoded_content)
          handle_error(ErrorCodes::UPLOAD_FAILED, I18n.t('storage.errors.upload_failed'),
                      StandardError.new("FTP upload operation failed"))
        end

        {
          blob_id: blob_id,
          size: decoded_content.bytesize,
          storage_provider: 'ftp',
          reference_path: "ftp://#{@client.host}/#{File.join(@client.directory, blob_id)}"
        }
      rescue Net::FTPPermError => e
        handle_error(ErrorCodes::UNAUTHORIZED, I18n.t('storage.errors.unauthorized_ftp'), e)
      rescue Net::FTPError => e
        handle_error(ErrorCodes::UPLOAD_FAILED, I18n.t('storage.errors.upload_failed'), e)
      rescue SocketError, Timeout::Error, Errno::ECONNREFUSED => e
        handle_error(ErrorCodes::CONNECTION_ERROR, I18n.t('storage.errors.connection_error', provider: 'FTP'), e)
      rescue => e
        handle_error(ErrorCodes::UNKNOWN_ERROR, I18n.t('storage.errors.unknown_error'), e)
      end
    end

    # Retrieve a blob by its id
    # @param blob_id [String] unique identifier for the blob
    # @return [String] base64 encoded content of the blob or nil if not found
    # @raise [Storage::StorageError] on failure with sanitized error information
    def retrieve(blob_id)
      begin
        content = @client.get_object(blob_id)
        
        return nil if content.nil?
        
        Base64.strict_encode64(content)
      rescue Net::FTPPermError => e
        handle_error(ErrorCodes::UNAUTHORIZED, I18n.t('storage.errors.unauthorized_ftp'), e)
      rescue Net::FTPError => e
        handle_error(ErrorCodes::DOWNLOAD_FAILED, I18n.t('storage.errors.download_failed'), e)
      rescue SocketError, Timeout::Error, Errno::ECONNREFUSED => e
        handle_error(ErrorCodes::CONNECTION_ERROR, I18n.t('storage.errors.connection_error', provider: 'FTP'), e)
      rescue => e
        handle_error(ErrorCodes::UNKNOWN_ERROR, I18n.t('storage.errors.unknown_error'), e)
      end
    end
  end
end
