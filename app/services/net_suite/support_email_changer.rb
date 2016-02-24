module NetSuite
  class SupportEmailChanger
    def initialize(message:)
      @message = message
    end

    def call
      message.gsub(
        /\w+@.+\.\w{3}/,
        ENV.fetch("SUPPORT_EMAIL", "api@namely.com")
      )
    end

    private

    attr_reader :message
  end
end
