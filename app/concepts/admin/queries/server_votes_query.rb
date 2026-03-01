module Admin
  module Queries
    class ServerVotesQuery < Search::Base
      include Search::ById
      include Search::ByEmail
      include Search::ByName

      private

      def scopes
        relation
          .left_joins(server: :game, account: :user)
          .merge(
            by_id("server_votes.id")
              .or(by_id("server_votes.server_id"))
              .or(by_id("server_votes.game_id"))
              .or(by_id("server_votes.account_id"))
              .or(by_name("servers.name"))
              .or(by_name("games.name"))
              .or(by_email("users.email"))
          )
      end
    end
  end
end
