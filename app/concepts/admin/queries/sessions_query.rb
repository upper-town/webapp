module Admin
  module Queries
    class SessionsQuery < Search::Base
      include Search::ById
      include Search::ByLastFour
      include Search::ByRemoteIp
      include Search::ByEmail

      private

      def scopes
        relation
          .left_joins(:user)
          .merge(
            by_id("sessions.id")
              .or(by_id("sessions.user_id"))
              .or(by_last_four("sessions.token_last_four"))
              .or(by_remote_ip("sessions.remote_ip"))
              .or(by_email("users.email"))
          )
      end
    end
  end
end
