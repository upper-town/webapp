# frozen_string_literal: true

module Admin
  module Queries
    class WebhookEventsQuery < Search::Base
      include Search::ById
      include Search::ByUuid
      include Search::ByName

      private

      def scopes
        relation
          .merge(
            by_id("webhook_events.id")
              .or(by_uuid("webhook_events.uuid"))
              .or(by_name("webhook_events.type"))
          )
      end
    end
  end
end
