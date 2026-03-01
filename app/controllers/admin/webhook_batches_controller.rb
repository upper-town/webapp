module Admin
  class WebhookBatchesController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::WebhookBatchesQuery.call(webhook_config_id: params[:webhook_config_id])
      @pagination = Pagination.new(
        Admin::Queries::WebhookBatchesQuery.call(WebhookBatch, relation, @search_term),
        request,
        per_page: 50
      )
      @webhook_batches = @pagination.results
      config_id = params[:webhook_config_id]
      @webhook_config = WebhookConfig.find_by(id: config_id) if config_id.present?

      render(status: :ok)
    end

    def show
      @webhook_batch = webhook_batch_from_params
    end

    private

    def webhook_batch_from_params
      WebhookBatch.includes(:config, :events).find(params[:id])
    end
  end
end
