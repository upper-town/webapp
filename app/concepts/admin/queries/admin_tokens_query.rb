module Admin
  module Queries
    class AdminTokensQuery < Search::Base
      include Search::ById
      include Search::ByLastFour
      include Search::ByEmail

      private

      def scopes
        relation
          .left_joins(:admin_user)
          .merge(
            by_id("admin_tokens.id")
              .or(by_id("admin_tokens.admin_user_id"))
              .or(by_last_four("admin_tokens.token_last_four"))
              .or(by_email("admin_users.email"))
          )
      end
    end
  end
end
