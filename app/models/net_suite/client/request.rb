module NetSuite
  class Client
    class Request
      if ENV['CLOUD_ELEMENTS_STAGING'].present?
        BASE_URL = "https://staging.cloud-elements.com/elements/api-v2"
      else
        BASE_URL = "https://api.cloud-elements.com/elements/api-v2"
      end

      def initialize(element_secret:, organization_secret:, user_secret:)
        @element_secret = element_secret
        @organization_secret = organization_secret
        @user_secret = user_secret
      end

      def submit_json(method, path, data)
        translate_response do
          RestClient.public_send(
            method,
            url(path),
            data.to_json,
            authorization: authorization,
            content_type: "application/json"
          )
        end
      end

      def get_json(path, paginated: false, params: {})
        if paginated
          get_paginated_json(path, params.dup)
        else
          translate_response do
            RestClient.get(
              url(path),
              authorization: authorization,
              content_type: "application/json"
            )
          end
        end
      end

      private

      def get_paginated_json(path, params)
        objects = []
        response = nil

        loop do
          results = translate_response do
            response = RestClient.get(
              url("#{path}?#{params.to_query}"),
              authorization: authorization,
              content_type: "application/json"
            )
          end

          results.each { |o| objects << o }

          next_page_token = response.headers[:elements_next_page_token]
          break if results.empty? || next_page_token.blank?

          params[:nextPage] = next_page_token
        end

        objects
      end

      def translate_response
        response = yield
        if response.present?
          JSON.parse(response)
        end
      rescue RestClient::Unauthorized => exception
        raise Unauthorized, exception.message
      rescue RestClient::Exception => exception
        validate_exception(exception)
      end

      def url(path)
        "#{BASE_URL}#{path}"
      end

      def authorization
        secrets.
          compact.
          map { |name, secret| [name, secret].join(" ") }.
          join(", ")
      end

      def secrets
        {
          "User" => user_secret,
          "Organization" => organization_secret,
          "Element" => element_secret
        }
      end

      def validate_exception(exception)
        case exception.response.body
        when /already an employee with external access/
          Rails.logger.info("netsuite error: external employee error")
          raise NetSuite::ApiError, exception, exception.backtrace
        else
          track_and_log_exception(exception)
        end
      end

      def track_and_log_exception(exception)
        Raygun.track_exception(exception)
        Rails.logger.error("netsuite error: #{exception}")
        Rails.logger.error("netsuite error: #{exception.response.body}")
        Rails.logger.error("netsuite error: #{exception.response.headers}")
        raise NetSuite::ApiError, exception, exception.backtrace
      end

      attr_reader :element_secret, :organization_secret, :user_secret
    end
  end
end
