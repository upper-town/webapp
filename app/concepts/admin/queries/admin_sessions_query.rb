# frozen_string_literal: true

module Admin
  module Queries
    class AdminSessionsQuery < Search::Base
      include Search::ById
      include Search::ByLastFour
      include Search::ByRemoteIp
      include Search::ByEmail

      private

      def scopes
        relation
          .left_joins(:admin_user)
          .merge(
            by_id("admin_sessions.id")
              .or(by_id("admin_sessions.admin_user_id"))
              .or(by_last_four("admin_sessions.token_last_four"))
              .or(by_remote_ip("admin_sessions.remote_ip"))
              .or(by_email("admin_users.email"))
          )
      end
    end
  end
end
