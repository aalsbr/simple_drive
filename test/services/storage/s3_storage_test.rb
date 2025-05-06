require 'test_helper'

module Storage
  class S3StorageTest < ActiveSupport::TestCase
    setup do
      # Create a mock S3 client for testing
      @mock_client = mock('S3Client')
      @storage = S3Storage.new(client: @mock_client)
    end
    
    test "store encodes content and calls client with correct parameters" do
      blob_id = 'test-blob-123'
      content = Base64.strict_encode64('test content')
      decoded_content = Base64.strict_decode64(content)
      
      # Set up expectations for the mock client
      @mock_client.expects(:put_object).with(blob_id, decoded_content).returns(OpenStruct.new(code: 200))
      @mock_client.expects(:bucket).returns('test-bucket').at_least_once
      
      # Call the method
      result = @storage.store(blob_id, content)
      
      # Verify results
      assert_equal blob_id, result[:blob_id]
      assert_equal decoded_content.bytesize, result[:size]
      assert_equal 's3', result[:storage_provider]
      assert_equal "s3://test-bucket/#{blob_id}", result[:reference_path]
    end
    
    test "store raises StorageError with unauthorized error code on 401" do
      blob_id = 'test-blob-123'
      content = Base64.strict_encode64('test content')
      
      # Mock a 401 response
      @mock_client.expects(:put_object).returns(OpenStruct.new(code: 401, body: 'Unauthorized'))
      
      # Call method and expect error
      error = assert_raises(StorageError) do
        @storage.store(blob_id, content)
      end
      
      # Verify error details
      assert_equal ErrorCodes::UNAUTHORIZED, error.code
      assert_equal I18n.t('storage.errors.unauthorized_s3'), error.message
    end
    
    test "store raises StorageError with not found error code on 404" do
      blob_id = 'test-blob-123'
      content = Base64.strict_encode64('test content')
      
      # Mock a 404 response
      @mock_client.expects(:put_object).returns(OpenStruct.new(code: 404, body: 'Not Found'))
      
      # Call method and expect error
      error = assert_raises(StorageError) do
        @storage.store(blob_id, content)
      end
      
      # Verify error details
      assert_equal ErrorCodes::NOT_FOUND, error.code
      assert_equal I18n.t('storage.errors.not_found_s3'), error.message
    end
    
    test "store raises StorageError with upload failed error code on other errors" do
      blob_id = 'test-blob-123'
      content = Base64.strict_encode64('test content')
      
      # Mock a 500 response
      @mock_client.expects(:put_object).returns(OpenStruct.new(code: 500, body: 'Server Error'))
      
      # Call method and expect error
      error = assert_raises(StorageError) do
        @storage.store(blob_id, content)
      end
      
      # Verify error details
      assert_equal ErrorCodes::UPLOAD_FAILED, error.code
      assert_equal I18n.t('storage.errors.upload_failed'), error.message
    end
    
    test "retrieve returns nil when content not found" do
      blob_id = 'non-existent-blob'
      
      # Mock a 404 response
      @mock_client.expects(:get_object).with(blob_id).returns(OpenStruct.new(code: 404))
      
      # Call method
      result = @storage.retrieve(blob_id)
      
      # Verify result is nil
      assert_nil result
    end
    
    test "retrieve returns base64 encoded content on success" do
      blob_id = 'test-blob-123'
      raw_content = 'test content for retrieval'
      
      # Mock a successful response
      @mock_client.expects(:get_object).with(blob_id).returns(OpenStruct.new(
        code: 200,
        body: raw_content
      ))
      
      # Call method
      result = @storage.retrieve(blob_id)
      
      # Verify result
      assert_equal Base64.strict_encode64(raw_content), result
    end
    
    test "retrieve raises StorageError with unauthorized error code on 401" do
      blob_id = 'test-blob-123'
      
      # Mock a 401 response
      @mock_client.expects(:get_object).with(blob_id).returns(OpenStruct.new(code: 401, body: 'Unauthorized'))
      
      # Call method and expect error
      error = assert_raises(StorageError) do
        @storage.retrieve(blob_id)
      end
      
      # Verify error details
      assert_equal ErrorCodes::UNAUTHORIZED, error.code
      assert_equal I18n.t('storage.errors.unauthorized_s3'), error.message
    end
  end
end
