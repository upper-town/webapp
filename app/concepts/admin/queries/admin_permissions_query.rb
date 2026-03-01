module Admin
  module Queries
    class AdminPermissionsQuery < Search::Base
      include Search::ById
      include Search::ByName

      private

      def scopes
        relation
          .merge(
            by_id("admin_permissions.id")
              .or(by_name("admin_permissions.key"))
              .or(by_name("admin_permissions.description"))
          )
      end
    end
  end
end
