require 'net/ftp'
require 'tempfile'
require 'base64'
require 'logger'

module Clients
  module Storage
    # FTPClient handles direct communication with an FTP server
    # It encapsulates FTP connection management and file operations
    class FTPClient
      attr_reader :host, :username, :directory

      def initialize(options = {})
        @host = options[:host] || ENV['FTP_HOST']
        @username = options[:username] || ENV['FTP_USERNAME']
        @password = options[:password] || ENV['FTP_PASSWORD']
        @directory = options[:directory] || ENV['FTP_DIRECTORY'] || '/'
        @port = options[:port] || ENV['FTP_PORT'] || 21
        @passive = options[:passive] || ENV['FTP_PASSIVE'] == 'true' || true
        @logger = options[:logger] || Rails.logger

        raise ArgumentError, 'FTP host is required' unless @host
        raise ArgumentError, 'FTP username is required' unless @username
        raise ArgumentError, 'FTP password is required' unless @password
      end

      # Upload a file to the FTP server
      # @param key [String] the object key (path in FTP directory)
      # @param data [String] raw binary data to upload
      # @return [Boolean] success status
      def put_object(key, data)
        tempfile = create_tempfile(data)
        
        with_ftp_connection do |ftp|
          ensure_directory_exists(ftp, File.dirname(full_path(key)))
          ftp.putbinaryfile(tempfile.path, full_path(key))
          true
        end
      ensure
        tempfile.close
        tempfile.unlink
      end

      # Download a file from the FTP server
      # @param key [String] the object key (path in FTP directory)
      # @return [String, nil] file content or nil if not found
      def get_object(key)
        tempfile = Tempfile.new('ftp-download')
        
        with_ftp_connection do |ftp|
          begin
            ftp.getbinaryfile(full_path(key), tempfile.path)
            File.binread(tempfile.path)
          rescue Net::FTPPermError, Net::FTPReplyError => e
            @logger.error("FTP download error for #{key}: #{e.message}")
            nil
          end
        end
      ensure
        tempfile.close
        tempfile.unlink
      end

      private

      def create_tempfile(data)
        tempfile = Tempfile.new('ftp-upload')
        tempfile.binmode
        tempfile.write(data)
        tempfile.flush
        tempfile
      end

      def with_ftp_connection
        ftp = Net::FTP.new
        ftp.passive = @passive
        ftp.connect(@host, @port)
        ftp.login(@username, @password)
        
        yield(ftp)
      rescue Net::FTPError => e
        @logger.error("FTP error: #{e.message}")
        raise e
      ensure
        ftp&.close
      end

      def ensure_directory_exists(ftp, directory_path)
        return if directory_path == '/' || directory_path.empty?

        parent_dir = File.dirname(directory_path)
        ensure_directory_exists(ftp, parent_dir) unless parent_dir == '/'

        begin
          ftp.chdir(directory_path)
        rescue Net::FTPPermError
          # Directory doesn't exist, create it
          ftp.mkdir(directory_path)
        end
      end

      def full_path(key)
        File.join(@directory, key)
      end
    end
  end
end
