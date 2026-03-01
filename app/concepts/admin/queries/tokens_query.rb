module Admin
  module Queries
    class TokensQuery < Search::Base
      include Search::ById
      include Search::ByLastFour
      include Search::ByEmail

      private

      def scopes
        relation
          .left_joins(:user)
          .merge(
            by_id("tokens.id")
              .or(by_id("tokens.user_id"))
              .or(by_last_four("tokens.token_last_four"))
              .or(by_email("users.email"))
          )
      end
    end
  end
end
