module Admin
  class WebhookEventsFilterQuery < Filter::Base
    include Filter::ByValues

    private

    def scopes
      by_values(relation, params[:webhook_config_id], column: :webhook_config_id)
    end
  end
end
