module Admin
  module Queries
    class AdminRolesQuery < Search::Base
      include Search::ById
      include Search::ByName

      private

      def scopes
        relation
          .merge(
            by_id("admin_roles.id")
              .or(by_name("admin_roles.key"))
              .or(by_name("admin_roles.description"))
          )
      end
    end
  end
end
