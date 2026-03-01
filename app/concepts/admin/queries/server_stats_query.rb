module Admin
  module Queries
    class ServerStatsQuery < Search::Base
      include Search::ById
      include Search::ByName

      private

      def scopes
        relation
          .left_joins(:server, :game)
          .merge(
            by_id("server_stats.id")
              .or(by_id("server_stats.server_id"))
              .or(by_id("server_stats.game_id"))
              .or(by_name("servers.name"))
              .or(by_name("games.name"))
          )
      end
    end
  end
end
