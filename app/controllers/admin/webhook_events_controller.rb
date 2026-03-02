module Admin
  class WebhookEventsController < BaseController
    def index
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::WebhookEventsQuery.call(
        webhook_config_id: params[:webhook_config_id],
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @webhook_events = @pagination.results
      config_id = params[:webhook_config_id]
      @webhook_config = WebhookConfig.find_by(id: config_id) if config_id.present?

      render(status: :ok)
    end

    def show
      @webhook_event = webhook_event_from_params
    end

    private

    def webhook_event_from_params
      WebhookEvent.includes(:config, :batch).find(params[:id])
    end
  end
end
