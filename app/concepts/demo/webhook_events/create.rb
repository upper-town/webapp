# frozen_string_literal: true

module Demo
  module WebhookEvents
    class Create
      include Callable

      attr_reader :webhook_event_hashes

      def initialize(webhook_event_hashes)
        @webhook_event_hashes = webhook_event_hashes
      end

      def call
        return if webhook_event_hashes.blank?

        DemoWebhookEvent.insert_all(webhook_event_hashes)
      end
    end
  end
end
