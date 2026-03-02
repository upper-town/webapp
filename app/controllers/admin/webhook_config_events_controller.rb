module Admin
  class WebhookConfigEventsController < BaseController
    def index
      @webhook_config = WebhookConfig.find(params[:id])
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::WebhookEventsQuery.call(
        webhook_config_id: @webhook_config.id,
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @webhook_events = @pagination.results
    end
  end
end
