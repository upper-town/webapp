module Servers
  module VerifyAccounts
    class DownloadAndParseJsonFile
      include Callable

      class Result < ApplicationResult
        attribute :parsed_body
      end

      attr_reader :server, :json_file_path, :connection

      def initialize(server, json_file_path)
        @server = server
        @json_file_path = json_file_path

        @connection = build_connection
      end

      def call
        response = connection.get(json_file_path)

        validator = ValidateJsonFile.new(response.body)

        if validator.valid?
          Result.success(parsed_body: response.body)
        else
          result = Result.new ; validator.errors.each { result.add_error(it) }
          result
        end
      rescue Faraday::ClientError, Faraday::ServerError => e
        Result.failure(I18n.t("servers.verify_accounts.errors.request_failed", error: e))
      rescue Faraday::ParsingError, JSON::ParserError, TypeError => e
        Result.failure(I18n.t("servers.verify_accounts.errors.invalid_json", error: e))
      rescue Faraday::Error => e
        Result.failure(I18n.t("servers.verify_accounts.errors.connection_failed", error: e))
      end

      private

      def build_connection
        Faraday.new(url: server.site_url) do |builder|
          builder.response :json
          builder.response :raise_error
        end
      end
    end
  end
end
