# frozen_string_literal: true

module Admin
  module Queries
    class AccountsQuery < Search::Base
      include Search::ById
      include Search::ByUuid
      include Search::ByEmail

      private

      def scopes
        relation
          .left_joins(:user)
          .merge(
            by_id("accounts.id")
              .or(by_id("accounts.user_id"))
              .or(by_uuid("accounts.uuid"))
              .or(by_email("users.email"))
          )
      end
    end
  end
end
