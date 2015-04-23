module Icims
  class AuthorizedRequest < SimpleDelegator
    HMAC_SHA256_HEADER = "x-icims-v1-hmac-sha256"

    def initialize(connection:, request:)
      super(request)
      @connection = connection
    end

    alias :request :__getobj__

    def headers
      @headers ||= {
        "content-type" => "application/json",
        "host" => uri.host,
        "x-icims-date" => current_time.iso8601,
        "x-icims-content-sha256" => hashed_payload,
      }
    end

    def canonical_request
      [
        request.method.upcase,
        canonical_uri,
        canonical_query,
        canonical_headers,
        "",
        requested_headers,
      ].join("\n")
    end

    def string_to_sign
      [
        HMAC_SHA256_HEADER,
        current_time.iso8601,
        digest.hexdigest(canonical_request),
      ].join("\n")
    end

    def signature
      OpenSSL::HMAC.hexdigest(digest, connection.key, string_to_sign)
    end

    def authorization_header
      [
        "x-icims-v1-hmac-sha256 user=#{connection.username}",
        "signedheaders=#{requested_headers}",
        "signature=#{signature}",
      ].join(", ")
    end

    def execute
      request = RestClient::Request.new(
        method: request.method,
        url: url,
        headers: headers.merge(
          "Authorization" => authorization_header,
        ),
        payload: payload,
      )
      Rails.logger.info("ICIMS request START")
      Rails.logger.info(request.url)
      Rails.logger.info(request.method)
      Rails.logger.info(request.headers)
      Rails.logger.info(request.payload)
      Rails.logger.info("ICIMS request END")
      request.execute
    end

    private

    attr_reader :connection

    def canonical_headers
      headers.map do |header, value|
        [header, value].join(":")
      end.sort.join("\n")
    end

    def requested_headers
      headers.keys.sort.join(";")
    end

    def current_time
      @current_time ||= Time.current
    end

    def canonical_uri
      uri.path
    end

    def canonical_query
      uri.query
    end

    def payload
      @payload ||= request.payload.to_s
    end

    def uri
      URI.parse(url)
    end

    def digest
      OpenSSL::Digest::SHA256.new
    end

    def hashed_payload
      digest.hexdigest(payload)
    end
  end
end
