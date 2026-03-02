module Admin
  class WebhookBatchesSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "webhook_batches.id",
        "status" => "webhook_batches.status",
        "created_at" => "webhook_batches.created_at"
      }
    end
  end
end
