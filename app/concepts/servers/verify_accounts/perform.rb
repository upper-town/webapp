module Servers
  module VerifyAccounts
    class Perform
      include Callable

      attr_reader :server, :json_file_path

      def initialize(server, current_time = Time.current)
        @server = server
        @current_time = current_time
        @json_file_path = "uppertown_#{server.site_url_checksum}.json"
      end

      def call
        result = VerifyAccounts::CheckJsonFileMetadata.call(server, json_file_path)
        return result if result.failure?

        result = VerifyAccounts::DownloadAndParseJsonFile.call(server, json_file_path)
        return result if result.failure?

        parsed_body = result.parsed_body
        account_uuids = Array(parsed_body["accounts"] || [])

        result = check_accounts_exist(account_uuids)
        return result if result.failure?

        upsert_server_accounts(account_uuids, @current_time)
      end

      private

      def check_accounts_exist(account_uuids)
        result = Result.new
        existing_uuids = Account.where(uuid: account_uuids).pluck(:uuid)
        missing = account_uuids - existing_uuids

        missing.each do |uuid|
          result.add_error(I18n.t("servers.verify_accounts.errors.account_does_not_exist", uuid:))
        end

        result
      end

      def upsert_server_accounts(account_uuids, time)
        account_ids = Account.where(uuid: account_uuids).pluck(:id)

        if account_ids.empty?
          ServerAccount
            .where(server:)
            .update_all(verified_at: nil)

          Result.failure(I18n.t("servers.verify_accounts.errors.empty_accounts_array", path: json_file_path))
        else
          ApplicationRecord.transaction do
            ServerAccount
              .where(server:)
              .where.not(account_id: account_ids)
              .update_all(verified_at: nil)

            ServerAccount.upsert_all(
              account_ids.map do |account_id|
                {
                  account_id:,
                  server_id: server.id,
                  verified_at: time
                }
              end,
              unique_by: [:account_id, :server_id]
            )
          end

          Result.success
        end
      end
    end
  end
end
