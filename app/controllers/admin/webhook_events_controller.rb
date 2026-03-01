module Admin
  class WebhookEventsController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::WebhookEventsQuery.call(webhook_config_id: params[:webhook_config_id])
      @pagination = Pagination.new(
        Admin::Queries::WebhookEventsQuery.call(WebhookEvent, relation, @search_term),
        request,
        per_page: 50
      )
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
