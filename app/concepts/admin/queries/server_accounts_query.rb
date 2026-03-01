module Admin
  module Queries
    class ServerAccountsQuery < Search::Base
      include Search::ById
      include Search::ByEmail
      include Search::ByName

      private

      def scopes
        relation
          .left_joins(server: :game, account: :user)
          .merge(
            by_id("server_accounts.id")
              .or(by_id("server_accounts.server_id"))
              .or(by_id("server_accounts.account_id"))
              .or(by_name("servers.name"))
              .or(by_email("users.email"))
          )
      end
    end
  end
end
