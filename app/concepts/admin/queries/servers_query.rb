# frozen_string_literal: true

module Admin
  module Queries
    class ServersQuery < Search::Base
      include Search::ById
      include Search::ByName

      private

      def scopes
        relation
          .left_joins(:game)
          .merge(
            by_id("servers.id")
              .or(by_id("servers.game_id"))
              .or(by_name("servers.name"))
              .or(by_name("games.name"))
          )
      end
    end
  end
end
