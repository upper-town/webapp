module Admin
  class WebhookEventsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "webhook_events.id",
        "type" => "webhook_events.type",
        "created_at" => "webhook_events.created_at"
      }
    end
  end
end
