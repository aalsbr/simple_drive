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
      assert_equal error_code, error.code
      assert_equal message, error.message
      assert_equal original_error, error.original_error
    end

    test "handle_error works without original_error" do
      error_code = ErrorCodes::UPLOAD_FAILED
      message = "Upload failed message"

      # Test that handle_error works without an original error
      error = assert_raises(StorageError) do
        @storage.test_error_handling(error_code, message)
      end

      # Verify error attributes
      assert_equal error_code, error.code
      assert_equal message, error.message
      assert_nil error.original_error
    end

    test "StorageError includes error code in to_s output" do
      error = StorageError.new(
        code: ErrorCodes::UNAUTHORIZED,
        message: "Authentication failed",
        original_error: nil
      )

      # Check that to_s includes both code and message
      assert_match(/#{ErrorCodes::UNAUTHORIZED}/, error.to_s)
      assert_match(/Authentication failed/, error.to_s)
    end

    test "StorageError preserves original error" do
      original = ArgumentError.new("Secret info that shouldn't be exposed")
      error = StorageError.new(
        code: ErrorCodes::CONFIGURATION_ERROR,
        message: "Configuration error occurred",
        original_error: original
      )

      # Verify original error is preserved but not exposed in message
      assert_equal original, error.original_error
      assert_not_match(/Secret info/, error.message)
      assert_not_match(/Secret info/, error.to_s)
    end
  end
end
