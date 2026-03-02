module Admin
  class WebhookConfigsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "webhook_configs.id",
        "url" => "webhook_configs.url",
        "created_at" => "webhook_configs.created_at"
      }
    end
  end
end
