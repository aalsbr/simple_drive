require 'base64'

class BlobValidator
  # Default validation options
  DEFAULT_OPTIONS = {
    max_size: 100.megabytes,                # 100MB max size
    allow_empty: false,                     # Don't allow empty blobs
    content_types: nil,                     # Allow all content types
    allowed_extensions: nil,                # Allow all extensions
    check_size_before_decode: true,         # Check base64 string length before decoding
    check_actual_decoding: true,            # Attempt to decode the content
    validate_magic_bytes: false             # Don't validate file signatures by default
  }.freeze

  # Common file signatures (magic bytes) for validation
  MAGIC_BYTES = {
    pdf: [%w[25 50 44 46]],                             # %PDF
    png: [%w[89 50 4E 47 0D 0A 1A 0A]],                  # PNG header
    jpg: [%w[FF D8 FF], %w[FF D8 FF E0], %w[FF D8 FF E1]], # JPEG headers
    gif: [%w[47 49 46 38]],                             # GIF8
    zip: [%w[50 4B 03 04]],                             # PK..
    docx: [%w[50 4B 03 04]],                            # PK.. (Office Open XML)
    xlsx: [%w[50 4B 03 04]]                             # PK.. (Office Open XML)
  }.freeze

  attr_reader :errors

  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    @errors = []
  end

  # Main validation method
  def validate(blob_id, content)
    @errors = []
    
    # Basic validations
    validate_presence(blob_id, content)
    return false if @errors.any?
    
    # Base64 format validation
    validate_base64_format(content)
    return false if @errors.any?
    
    # Check size before decoding (optimization)
    if @options[:check_size_before_decode]
      validate_base64_size(content)
      return false if @errors.any?
    end
    
    # Attempt to decode the content
    begin
      decoded_content = Base64.strict_decode64(content)
    rescue ArgumentError => e
      @errors << "#{I18n.t('validation.errors.invalid_base64')}: #{e.message}"
      return false
    end
    
    # Post-decode validations
    validate_decoded_content(decoded_content)
    validate_content_type(decoded_content) if @options[:content_types]
    validate_extension(blob_id) if @options[:allowed_extensions]
    validate_file_signature(decoded_content) if @options[:validate_magic_bytes]
    
    # Return validation result
    @errors.empty?
  end

  # Factory method for consistent validation configuration across the app
  def self.default_validator
    new(
      max_size: 50.megabytes,
      allow_empty: false,
      check_actual_decoding: true
    )
  end

  private

  def validate_presence(blob_id, content)
    @errors << I18n.t('validation.errors.required', field: 'Blob ID') if blob_id.blank?
    @errors << I18n.t('validation.errors.required', field: 'Content') if content.blank?
  end

  def validate_base64_format(content)
    # Strict base64 regex validation
    unless content =~ /^[A-Za-z0-9+\/]+=*$/
      @errors << I18n.t('validation.errors.invalid_base64')
    end
    
    # Check for padding correctness
    if content =~ /[^=]=[^=]/
      @errors << I18n.t('validation.errors.invalid_padding')
    end
  end

  def validate_base64_size(content)
    # Estimate the decoded size from base64 string
    estimated_size = (content.length * 3) / 4
    if estimated_size > @options[:max_size]
      @errors << I18n.t('validation.errors.size_exceeds', max_size: @options[:max_size])
    end
  end

  def validate_decoded_content(decoded_content)
    # Check decoded size
    if decoded_content.bytesize > @options[:max_size]
      @errors << I18n.t('validation.errors.size_exceeds_actual', 
                       actual_size: decoded_content.bytesize, 
                       max_size: @options[:max_size])
    end
    
    # Check if content is empty
    if !@options[:allow_empty] && decoded_content.empty?
      @errors << I18n.t('validation.errors.empty_not_allowed')
    end
  end

  def validate_content_type(decoded_content)
    # Stub for content type detection
    # In a real implementation, this would detect MIME type from the content
    # For now, we'll just assume this validation passes
  end

  def validate_extension(blob_id)
    return unless @options[:allowed_extensions].is_a?(Array)
    
    # Extract extension from blob_id if it has one
    extension = blob_id.to_s.split('.').last&.downcase
    if extension && !@options[:allowed_extensions].map(&:downcase).include?(extension)
      @errors << I18n.t('validation.errors.extension_not_allowed',
                       extension: extension,
                       allowed: @options[:allowed_extensions].join(', '))
    end
  end

  def validate_file_signature(decoded_content)
    # Skip for small files
    return if decoded_content.bytesize < 8
    
    # Check if the binary content starts with any of the known magic bytes
    file_type = detect_file_type(decoded_content)
    
    if @options[:validate_magic_bytes].is_a?(Array) && !@options[:validate_magic_bytes].include?(file_type)
      @errors << I18n.t('validation.errors.file_type_not_allowed',
                       type: file_type || 'unknown',
                       allowed: @options[:validate_magic_bytes].join(', '))
    end
  end

  def detect_file_type(decoded_content)
    # Convert first few bytes to hex for comparison
    first_bytes = decoded_content.byteslice(0, 8).bytes.map { |b| b.to_s(16).rjust(2, '0').upcase }
    
    # Check against known signatures
    MAGIC_BYTES.each do |type, signatures|
      signatures.each do |signature|
        return type if first_bytes.first(signature.size) == signature
      end
    end
    
    nil # Unknown file type
  end
end
