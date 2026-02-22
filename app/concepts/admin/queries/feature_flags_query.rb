# frozen_string_literal: true

module Admin
  module Queries
    class FeatureFlagsQuery < Search::Base
      include Search::ById
      include Search::ByName

      private

      def scopes
        relation
          .merge(
            by_id("feature_flags.id")
              .or(by_name("feature_flags.name"))
              .or(by_name("feature_flags.value"))
          )
      end
    end
  end
end
