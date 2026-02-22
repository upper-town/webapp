# frozen_string_literal: true

module Admin
  class WebhookEventsQuery
    include Callable

    def initialize(webhook_config_id: nil)
      @webhook_config_id = webhook_config_id
    end

    def call
      scope = WebhookEvent.includes(:config, :batch)
      scope = scope.where(webhook_config_id: @webhook_config_id) if @webhook_config_id.present?
      scope.order(id: :desc)
    end
  end
end
