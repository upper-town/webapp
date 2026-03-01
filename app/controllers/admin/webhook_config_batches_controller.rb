module Admin
  class WebhookConfigBatchesController < BaseController
    def index
      @webhook_config = WebhookConfig.find(params[:id])
      @search_term = params[:q]
      relation = Admin::WebhookBatchesQuery.new(webhook_config_id: @webhook_config.id).call
      @pagination = Pagination.new(
        Admin::Queries::WebhookBatchesQuery.call(WebhookBatch, relation, @search_term),
        request,
        per_page: 50
      )
      @webhook_batches = @pagination.results
    end
  end
end
