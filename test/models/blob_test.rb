require "test_helper"

class BlobTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    blob = Blob.new(
      blob_id: 'test-blob-123',
      size: 1024,
      storage_provider: 's3'
    )
    assert blob.valid?
  end
  
  test "should require blob_id" do
    blob = Blob.new(size: 1024, storage_provider: 's3')
    assert_not blob.valid?
    assert_includes blob.errors[:blob_id], "can't be blank"
  end
  
  test "should require size" do
    blob = Blob.new(blob_id: 'test-blob-123', storage_provider: 's3')
    assert_not blob.valid?
    assert_includes blob.errors[:size], "can't be blank"
  end
  
  test "should require storage_provider" do
    blob = Blob.new(blob_id: 'test-blob-123', size: 1024)
    assert_not blob.valid?
    assert_includes blob.errors[:storage_provider], "can't be blank"
  end
  
  test "should validate uniqueness of blob_id" do
    # Create first blob
    Blob.create!(
      blob_id: 'unique-blob-id',
      size: 1024,
      storage_provider: 's3'
    )
    
    # Attempt to create another with same ID
    duplicate = Blob.new(
      blob_id: 'unique-blob-id',
      size: 2048,
      storage_provider: 'ftp'
    )
    
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:blob_id], "has already been taken"
  end
  
  test "should allow different storage providers" do
    # Create blob with S3 provider
    s3_blob = Blob.new(
      blob_id: 's3-blob',
      size: 1024,
      storage_provider: 's3'
    )
    assert s3_blob.valid?
    
    # Create blob with FTP provider
    ftp_blob = Blob.new(
      blob_id: 'ftp-blob',
      size: 2048,
      storage_provider: 'ftp'
    )
    assert ftp_blob.valid?
  end
end
