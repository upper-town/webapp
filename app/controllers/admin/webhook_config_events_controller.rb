module Admin
  class WebhookConfigEventsController < BaseController
    def index
      @webhook_config = WebhookConfig.find(params[:id])
      @search_term = params[:q]
      relation = Admin::WebhookEventsQuery.new(webhook_config_id: @webhook_config.id).call
      @pagination = Pagination.new(
        Admin::Queries::WebhookEventsQuery.call(WebhookEvent, relation, @search_term),
        request,
        per_page: 50
      )
      @webhook_events = @pagination.results
    end
  end
end
