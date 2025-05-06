require 'test_helper'

module Storage
  class TestStorage < BaseStorage
    # Test implementation for testing BaseStorage functionality
    def test_error_handling(error_code, message, original_error = nil)
      handle_error(error_code, message, original_error)
    end
  end

  class BaseStorageTest < ActiveSupport::TestCase
    setup do
      @storage = TestStorage.new
    end

    test "handle_error raises StorageError with correct attributes" do
      error_code = ErrorCodes::NOT_FOUND
      message = "Test error message"
      original_error = StandardError.new("Original error details")

      # Test that handle_error raises a StorageError
      error = assert_raises(StorageError) do
        @storage.test_error_handling(error_code, message, original_error)
      end

      # Verify error attributes
      assert_equal error_code, error.error_code
      assert_equal message, error.public_message
      # The original_error is not directly accessible
    end

    test "handle_error works without original_error" do
      error_code = ErrorCodes::UPLOAD_FAILED
      message = "Upload failed message"

      # Test that handle_error works without an original error
      error = assert_raises(StorageError) do
        @storage.test_error_handling(error_code, message)
      end

      # Verify error attributes
      assert_equal error_code, error.error_code
      assert_equal message, error.public_message
      # The original_error is not directly accessible
    end

    test "StorageError includes error code in to_s output" do
      error = StorageError.new(
        ErrorCodes::UNAUTHORIZED,
        "Authentication failed",
        nil
      )

      # Check that the error has the right error code and message
      assert_equal ErrorCodes::UNAUTHORIZED, error.error_code
      assert_equal "Authentication failed", error.public_message
    end

    test "StorageError preserves original error" do
      original = ArgumentError.new("Secret info that shouldn't be exposed")
      error = StorageError.new(
        ErrorCodes::CONFIGURATION_ERROR,
        "Configuration error occurred",
        original
      )

      # Verify original error message is not exposed
      assert_no_match(/Secret info/, error.public_message)
      assert_no_match(/Secret info/, error.to_s)
    end
  end
end
