module Admin
  class WebhookBatchesQuery
    include Callable

    def initialize(
      webhook_config_id: nil,
      search_term: nil,
      relation: nil,
      sort_key: nil,
      sort_dir: nil
    )
      @webhook_config_id = webhook_config_id
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = @relation || WebhookBatch.includes(:config, :events)
      relation = Admin::WebhookBatchesFilterQuery.call(
        relation,
        webhook_config_id: @webhook_config_id
      )
      relation = Admin::WebhookBatchesSearchQuery.call(WebhookBatch, relation, @search_term)
      Admin::WebhookBatchesSortQuery.call(relation, sort_key: @sort_key, sort_dir: @sort_dir)
    end
  end
end
