# This initializer silences specific warning messages that occur due to conflicts
# between Ruby's built-in net libraries and the newer net gems

# Create a custom warning processor to filter out specific warnings
module FilteredWarnings
  class << self
    # Keep track of warnings we've seen to avoid duplicates
    def seen_warnings
      @seen_warnings ||= Set.new
    end

    # Filter warnings we want to suppress
    def suppress?(message)
      return true if message.include?('already initialized constant Net::ProtocRetryError')
      return true if message.include?('already initialized constant Net::BufferedIO::BUFSIZE')
      return true if message.include?('already initialized constant Net::NetPrivate::Socket')
      return true if message.include?('WARNING: The method will be renamed to "openapi_endpoint"')
      
      # For any other warning, only show it once
      if seen_warnings.include?(message)
        true
      else
        seen_warnings << message
        false
      end
    end
    
    # Process warnings through our filter
    def process(message)
      suppress?(message) ? nil : message
    end
  end
 end

# Only set up our warning processor in development and test environments
if Rails.env.development? || Rails.env.test?
  require 'warning'
  Warning.process { |warning| FilteredWarnings.process(warning) }

  # Pre-load all the net-protocol constants to avoid repeated warnings
  # even with our filter (belt and suspenders approach)
  original_verbose = $VERBOSE
  $VERBOSE = nil
  
  require 'net/protocol'
  require 'net/http'
  require 'net/ftp'
  
  $VERBOSE = original_verbose
end
