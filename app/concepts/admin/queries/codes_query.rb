module Admin
  module Queries
    class CodesQuery < Search::Base
      include Search::ById
      include Search::ByEmail

      private

      def scopes
        relation
          .left_joins(:user)
          .merge(
            by_id("codes.id")
              .or(by_id("codes.user_id"))
              .or(by_email("users.email"))
          )
      end
    end
  end
end
