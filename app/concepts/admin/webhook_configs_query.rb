module Admin
  class WebhookConfigsQuery
    include Callable

    def call
      WebhookConfig.includes(:source).order(id: :desc)
    end
  end
end
