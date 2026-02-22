# frozen_string_literal: true

module Admin
  class WebhookBatchesQuery
    include Callable

    def initialize(webhook_config_id: nil)
      @webhook_config_id = webhook_config_id
    end

    def call
      scope = WebhookBatch.includes(:config, :events)
      scope = scope.where(webhook_config_id: @webhook_config_id) if @webhook_config_id.present?
      scope.order(id: :desc)
    end
  end
end
