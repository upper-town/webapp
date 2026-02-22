# frozen_string_literal: true

module Admin
  module Queries
    class WebhookBatchesQuery < Search::Base
      include Search::ById
      include Search::ByName

      private

      def scopes
        relation
          .merge(
            by_id("webhook_batches.id")
              .or(by_name("webhook_batches.status"))
          )
      end
    end
  end
end
