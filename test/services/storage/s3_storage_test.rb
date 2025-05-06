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
      
      # Create a mock HTTP response
      success_response = stub('HTTPResponse')
      success_response.stubs(:code).returns(200)
      success_response.stubs(:body).returns('')
      
      # Set up stubs for the client
      @mock_client.stubs(:put_object).returns(success_response)
      @mock_client.stubs(:bucket).returns('simple-drive-uploads')
      
      # Call the method
      result = @storage.store(blob_id, content)
      
      # Verify results
      assert_equal blob_id, result[:blob_id]
      assert_equal decoded_content.bytesize, result[:size]
      assert_equal 's3', result[:storage_provider]
      assert_equal "s3://simple-drive-uploads/#{blob_id}", result[:reference_path]
    end
    
    test "retrieve returns base64 encoded content on success" do
      blob_id = 'test-blob-123'
      test_content = 'test content'
      
      # Create a mock HTTP response
      success_response = stub('HTTPResponse')
      success_response.stubs(:code).returns(200)
      success_response.stubs(:body).returns(test_content)
      
      # Set up stubs for the client
      @mock_client.stubs(:get_object).returns(success_response)
      
      # Call the method
      result = @storage.retrieve(blob_id)
      
      # Verify results
      assert_equal Base64.strict_encode64(test_content), result
    end
    
    test "retrieve returns nil when content not found" do
      blob_id = 'non-existent-blob'
      
      # Create a mock HTTP response for 404
      not_found_response = stub('HTTPResponse')
      not_found_response.stubs(:code).returns(404)
      not_found_response.stubs(:body).returns('')
      
      # Set up stubs for the client
      @mock_client.stubs(:get_object).returns(not_found_response)
      
      # Call the method
      result = @storage.retrieve(blob_id)
      
      # Verify results
      assert_nil result
    end
  end
end
