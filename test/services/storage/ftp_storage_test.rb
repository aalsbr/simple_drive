require 'test_helper'

module Storage
  class FTPStorageTest < ActiveSupport::TestCase
    setup do
      # Create a mock FTP client for testing
      @mock_client = mock('FTPClient')
      @storage = FTPStorage.new(client: @mock_client)
    end
    
    test "store encodes content and calls client with correct parameters" do
      blob_id = 'test-blob-123'
      content = Base64.strict_encode64('test content')
      decoded_content = Base64.strict_decode64(content)
      
      # Set up expectations for the mock client
      @mock_client.expects(:put_object).with(blob_id, decoded_content).returns(true)
      @mock_client.expects(:host).returns('ftp.example.com').at_least_once
      @mock_client.expects(:directory).returns('/files').at_least_once
      
      # Call the method
      result = @storage.store(blob_id, content)
      
      # Verify results
      assert_equal blob_id, result[:blob_id]
      assert_equal decoded_content.bytesize, result[:size]
      assert_equal 'ftp', result[:storage_provider]
      assert_equal "ftp://ftp.example.com/#{File.join('/files', blob_id)}", result[:reference_path]
    end
    
    test "store raises StorageError when FTP operation fails" do
      blob_id = 'test-blob-123'
      content = Base64.strict_encode64('test content')
      
      # Mock a failed FTP operation
      @mock_client.expects(:put_object).returns(false)
      
      # Call method and expect error
      error = assert_raises(StorageError) do
        @storage.store(blob_id, content)
      end
      
      # Verify error details
      assert_equal ErrorCodes::UPLOAD_FAILED, error.code
      assert_equal I18n.t('storage.errors.upload_failed'), error.message
    end
    
    test "store handles FTP permission errors" do
      blob_id = 'test-blob-123'
      content = Base64.strict_encode64('test content')
      
      # Mock a permission error
      @mock_client.expects(:put_object).raises(Net::FTPPermError.new('550 Permission denied'))
      
      # Call method and expect error
      error = assert_raises(StorageError) do
        @storage.store(blob_id, content)
      end
      
      # Verify error details
      assert_equal ErrorCodes::UNAUTHORIZED, error.code
      assert_equal I18n.t('storage.errors.unauthorized_ftp'), error.message
    end
    
    test "store handles connection errors" do
      blob_id = 'test-blob-123'
      content = Base64.strict_encode64('test content')
      
      # Mock a connection error
      @mock_client.expects(:put_object).raises(SocketError.new('Failed to connect'))
      
      # Call method and expect error
      error = assert_raises(StorageError) do
        @storage.store(blob_id, content)
      end
      
      # Verify error details
      assert_equal ErrorCodes::CONNECTION_ERROR, error.code
    end
    
    test "retrieve returns nil when content not found" do
      blob_id = 'non-existent-blob'
      
      # Mock a nil response (not found)
      @mock_client.expects(:get_object).with(blob_id).returns(nil)
      
      # Call method
      result = @storage.retrieve(blob_id)
      
      # Verify result is nil
      assert_nil result
    end
    
    test "retrieve returns base64 encoded content on success" do
      blob_id = 'test-blob-123'
      raw_content = 'test content for retrieval'
      
      # Mock a successful response
      @mock_client.expects(:get_object).with(blob_id).returns(raw_content)
      
      # Call method
      result = @storage.retrieve(blob_id)
      
      # Verify result
      assert_equal Base64.strict_encode64(raw_content), result
    end
    
    test "retrieve handles FTP permission errors" do
      blob_id = 'test-blob-123'
      
      # Mock a permission error
      @mock_client.expects(:get_object).raises(Net::FTPPermError.new('550 Permission denied'))
      
      # Call method and expect error
      error = assert_raises(StorageError) do
        @storage.retrieve(blob_id)
      end
      
      # Verify error details
      assert_equal ErrorCodes::UNAUTHORIZED, error.code
      assert_equal I18n.t('storage.errors.unauthorized_ftp'), error.message
    end
    
    test "retrieve handles general FTP errors" do
      blob_id = 'test-blob-123'
      
      # Mock a general FTP error
      @mock_client.expects(:get_object).raises(Net::FTPError.new('General FTP error'))
      
      # Call method and expect error
      error = assert_raises(StorageError) do
        @storage.retrieve(blob_id)
      end
      
      # Verify error details
      assert_equal ErrorCodes::DOWNLOAD_FAILED, error.code
    end
  end
end
