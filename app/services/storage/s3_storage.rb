require 'base64'
require_relative '../../../app/clients/storage/s3_client'

module Storage
  class S3Storage < BaseStorage
    # Initialize the S3Storage service
    # @param options [Hash] configuration options for S3
    def initialize(options = {})
      @client = ::Clients::Storage::S3Client.new(options)
    end

    # Store a blob with the given id and content
    # @param blob_id [String] unique identifier for the blob
    # @param content [String] base64 encoded content to store
    # @return [Hash] metadata about the stored blob
    # @raise [Storage::StorageError] on failure with sanitized error information
    def store(blob_id, content)
      begin
        decoded_content = Base64.strict_decode64(content)
        response = @client.put_object(blob_id, decoded_content)

        unless response.code.to_i.between?(200, 299)
          case response.code.to_i
          when 401, 403
            handle_error(ErrorCodes::UNAUTHORIZED, I18n.t('storage.errors.unauthorized_s3'), 
                        StandardError.new("S3 authorization failed: #{response.code} #{response.body}"))
          when 404
            handle_error(ErrorCodes::NOT_FOUND, I18n.t('storage.errors.not_found_s3'), 
                        StandardError.new("S3 resource not found: #{response.code} #{response.body}"))
          else
            handle_error(ErrorCodes::UPLOAD_FAILED, I18n.t('storage.errors.upload_failed'), 
                        StandardError.new("S3 upload failed: #{response.code} #{response.body}"))
          end
        end

        {
          blob_id: blob_id,
          size: decoded_content.bytesize,
          storage_provider: 's3',
          reference_path: "s3://#{@client.bucket}/#{blob_id}"
        }
      rescue URI::InvalidURIError, SocketError, Timeout::Error, Errno::ECONNREFUSED => e
        handle_error(ErrorCodes::CONNECTION_ERROR, "Could not connect to storage service", e)
      rescue => e
        handle_error(ErrorCodes::UNKNOWN_ERROR, "An unexpected error occurred while storing the file", e)
      end
    end

    # Retrieve a blob by its id
    # @param blob_id [String] unique identifier for the blob
    # @return [String] base64 encoded content of the blob or nil if not found
    # @raise [Storage::StorageError] on failure with sanitized error information
    def retrieve(blob_id)
      begin
        response = @client.get_object(blob_id)

        return nil if response.code.to_i == 404

        unless response.code.to_i.between?(200, 299)
          case response.code.to_i
          when 401, 403
            handle_error(ErrorCodes::UNAUTHORIZED, I18n.t('storage.errors.unauthorized_s3'), 
                        StandardError.new("S3 authorization failed: #{response.code} #{response.body}"))
          else
            handle_error(ErrorCodes::DOWNLOAD_FAILED, I18n.t('storage.errors.download_failed'), 
                        StandardError.new("S3 download failed: #{response.code} #{response.body}"))
          end
        end

        Base64.strict_encode64(response.body)
      rescue URI::InvalidURIError, SocketError, Timeout::Error, Errno::ECONNREFUSED => e
        handle_error(ErrorCodes::CONNECTION_ERROR, I18n.t('storage.errors.connection_error', provider: 'S3'), e)
      rescue => e
        handle_error(ErrorCodes::UNKNOWN_ERROR, I18n.t('storage.errors.unknown_error'), e)
      end
    end
  end
end
