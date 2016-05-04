module NetSuite
  # Wraps HTTP errors from Cloud Elements. Attempts to parse a
  # human-readable error message from the response.
  class ApiError < StandardError
    attr_reader :http_code

    def initialize(exception)
      @response = exception.response
      @http_code = exception.http_code
    end

    def message
      response_data["providerMessage"] ||
        response_data["message"] ||
        "Unknown error"
    end

    def to_s
      "NetSuite API Error: #{http_code} - #{message}"
    end

    def track?
      !message.include?("Bad request")
    end

    private

    def response_data
      if @response.present?
        JSON.parse(@response)
      else
        {}
      end
    end
  end
end
