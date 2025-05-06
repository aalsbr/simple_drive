require "test_helper"

class BlobBinaryStorageTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    binary_storage = BlobBinaryStorage.new(
      blob_id: 'test-blob-123',
      content: Base64.strict_encode64('Test content')
    )
    assert binary_storage.valid?
  end
  
  test "should require blob_id" do
    binary_storage = BlobBinaryStorage.new(content: Base64.strict_encode64('Test content'))
    assert_not binary_storage.valid?
    assert_includes binary_storage.errors[:blob_id], "can't be blank"
  end
  
  test "should require content" do
    binary_storage = BlobBinaryStorage.new(blob_id: 'test-blob-123')
    assert_not binary_storage.valid?
    assert_includes binary_storage.errors[:content], "can't be blank"
  end
  
  test "should validate uniqueness of blob_id" do
    # Create first storage record
    BlobBinaryStorage.create!(
      blob_id: 'unique-binary-id',
      content: Base64.strict_encode64('First content')
    )
    
    # Attempt to create another with same ID
    duplicate = BlobBinaryStorage.new(
      blob_id: 'unique-binary-id',
      content: Base64.strict_encode64('Different content')
    )
    
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:blob_id], "has already been taken"
  end
  
  test "should handle large content" do
    # Create some larger content (16KB)
    large_content = 'x' * 16384
    encoded_content = Base64.strict_encode64(large_content)
    
    # Store the large content
    binary_storage = BlobBinaryStorage.new(
      blob_id: 'large-content-blob',
      content: encoded_content
    )
    
    # It should be valid
    assert binary_storage.valid?
    
    # Save it and ensure it persists correctly
    assert binary_storage.save
    
    # Reload from database and check content is intact
    reloaded = BlobBinaryStorage.find_by(blob_id: 'large-content-blob')
    assert_equal encoded_content, reloaded.content
  end
end
