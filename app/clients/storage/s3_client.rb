require 'base64'
require 'net/http'
require 'uri'
require 'openssl'
require 'digest'
require 'time'

module Clients
  module Storage
    # S3Client handles direct API interactions with AWS S3 service
    # It encapsulates AWS authentication, request signing, and HTTP communication
    class S3Client
      attr_reader :bucket, :region

      def initialize(options = {})
        @bucket = options[:bucket] || ENV['S3_BUCKET_NAME']
        @region = options[:region] || ENV['AWS_REGION'] || 'us-east-1'
        @access_key = options[:access_key] || ENV['AWS_ACCESS_KEY_ID']
        @secret_key = options[:secret_key] || ENV['AWS_SECRET_ACCESS_KEY']

        raise ArgumentError, 'S3 bucket name is required' unless @bucket
        raise ArgumentError, 'AWS access key ID is required' unless @access_key
        raise ArgumentError, 'AWS secret access key is required' unless @secret_key
      end

      # Uploads a file to S3
      # @param key [String] the object key (path in bucket)
      # @param data [String] raw binary data to upload
      # @return [Net::HTTPResponse] the HTTP response
      def put_object(key, data)
        uri = build_uri(key)
        time = Time.now.utc
        timestamp = time.strftime('%Y%m%dT%H%M%SZ')
        datestamp = time.strftime('%Y%m%d')
        payload_hash = Digest::SHA256.hexdigest(data)

        headers = build_headers('PUT', key, timestamp, datestamp, payload_hash)
        headers['Content-Type'] = 'application/octet-stream'
        headers['Content-Length'] = data.bytesize.to_s

        request = Net::HTTP::Put.new(uri)
        headers.each { |k, v| request[k] = v }
        request.body = data

        perform_request(uri, request)
      end

      # Downloads a file from S3
      # @param key [String] the object key (path in bucket)
      # @return [Net::HTTPResponse] the HTTP response
      def get_object(key)
        uri = build_uri(key)
        time = Time.now.utc
        timestamp = time.strftime('%Y%m%dT%H%M%SZ')
        datestamp = time.strftime('%Y%m%d')

        headers = build_headers('GET', key, timestamp, datestamp, 'UNSIGNED-PAYLOAD')

        request = Net::HTTP::Get.new(uri)
        headers.each { |k, v| request[k] = v }

        perform_request(uri, request)
      end

      private

      def build_uri(key)
        URI("https://#{@bucket}.s3.#{@region}.amazonaws.com/#{key}")
      end

      def build_headers(method, key, timestamp, datestamp, payload_hash)
        uri = build_uri(key)
        canonical_headers = {
          'host' => uri.host,
          'x-amz-content-sha256' => payload_hash,
          'x-amz-date' => timestamp
        }

        signed_headers = canonical_headers.keys.sort.join(';')

        canonical_request = [
          method,
          "/#{key}",
          '',
          canonical_headers.map { |k, v| "#{k}:#{v}" }.join("\n") + "\n",
          signed_headers,
          payload_hash
        ].join("\n")

        credential_scope = "#{datestamp}/#{@region}/s3/aws4_request"
        string_to_sign = [
          'AWS4-HMAC-SHA256',
          timestamp,
          credential_scope,
          Digest::SHA256.hexdigest(canonical_request)
        ].join("\n")

        signature = sign_v4(@secret_key, datestamp, @region, 's3', string_to_sign)
        authorization = [
          "AWS4-HMAC-SHA256 Credential=#{@access_key}/#{credential_scope}",
          "SignedHeaders=#{signed_headers}",
          "Signature=#{signature}"
        ].join(', ')

        {
          'Authorization' => authorization,
          'x-amz-content-sha256' => payload_hash,
          'x-amz-date' => timestamp
        }
      end

      def perform_request(uri, request)
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
      end

      def sign(key, msg)
        OpenSSL::HMAC.digest('sha256', key, msg)
      end

      def sign_v4(secret, date, region, service, string_to_sign)
        k_date = sign("AWS4" + secret, date)
        k_region = sign(k_date, region)
        k_service = sign(k_region, service)
        k_signing = sign(k_service, "aws4_request")
        OpenSSL::HMAC.hexdigest('sha256', k_signing, string_to_sign)
      end
    end
  end
end
