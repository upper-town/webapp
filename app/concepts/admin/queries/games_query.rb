module Admin
  module Queries
    class GamesQuery < Search::Base
      include Search::ById
      include Search::ByName

      private

      def scopes
        relation
          .merge(
            by_id("games.id")
              .or(by_name("games.name"))
              .or(by_name("games.slug"))
          )
      end
    end
  end
end
