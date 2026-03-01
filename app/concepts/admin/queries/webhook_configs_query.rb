module Admin
  module Queries
    class WebhookConfigsQuery < Search::Base
      include Search::ById
      include Search::ByName

      private

      def scopes
        relation
          .merge(
            by_id("webhook_configs.id")
              .or(by_name("webhook_configs.url"))
          )
      end
    end
  end
end
