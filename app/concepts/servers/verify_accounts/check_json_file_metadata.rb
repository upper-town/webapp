module Servers
  module VerifyAccounts
    class CheckJsonFileMetadata
      include Callable

      JSON_FILE_MAX_SIZE = 512
      JSON_FILE_CONTENT_TYPE_PATTERN = %r{\bapplication/json\b}i

      attr_reader :server, :json_file_path, :connection

      def initialize(server, json_file_path)
        @server = server
        @json_file_path = json_file_path

        @connection = build_connection
      end

      def call
        response = connection.head(json_file_path)

        if response.headers["Content-Length"].to_i > JSON_FILE_MAX_SIZE
          Result.failure(I18n.t("servers.verify_accounts.errors.json_file_size_exceeded", max_size: JSON_FILE_MAX_SIZE))
        elsif !response.headers["Content-Type"].match?(JSON_FILE_CONTENT_TYPE_PATTERN)
          Result.failure(I18n.t("servers.verify_accounts.errors.json_content_type_invalid"))
        else
          Result.success
        end
      rescue Faraday::ClientError, Faraday::ServerError => e
        Result.failure(I18n.t("servers.verify_accounts.errors.request_failed", error: e))
      rescue Faraday::Error => e
        Result.failure(I18n.t("servers.verify_accounts.errors.connection_failed", error: e))
      end

      private

      def build_connection
        Faraday.new(url: server.site_url) do |builder|
          builder.response :raise_error
        end
      end
    end
  end
end
