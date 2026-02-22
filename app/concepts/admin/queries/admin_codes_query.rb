# frozen_string_literal: true

module Admin
  module Queries
    class AdminCodesQuery < Search::Base
      include Search::ById
      include Search::ByEmail

      private

      def scopes
        relation
          .left_joins(:admin_user)
          .merge(
            by_id("admin_codes.id")
              .or(by_id("admin_codes.admin_user_id"))
              .or(by_email("admin_users.email"))
          )
      end
    end
  end
end
