module Admin
  module Queries
    class AdminUsersQuery < Search::Base
      include Search::ById
      include Search::ByEmail

      private

      def scopes
        relation
          .merge(
            by_id("admin_users.id")
              .or(by_email("admin_users.email"))
          )
      end
    end
  end
end
