module Seeds
  class CreateWebhookConfigs
    include Callable

    def call
      result = WebhookConfig.insert_all(webhook_config_hashes)

      result.rows.flatten # webhook_config_ids
    end

    private

    def webhook_config_hashes
      [
        {
          source_type: "Server",
          source_id:   100,
          event_types: ["*"],
          method:      "POST",
          url:         "#{demo_site_url}/webhook_events",
          secret:      demo_webhook_secret,
          disabled_at: nil
        }
      ]
    end

    def demo_site_url
      ENV.fetch("DEMO_SITE_URL", "http://uppertown.test:3000/demo")
    end

    def demo_webhook_secret
      ENV.fetch("DEMO_WEBHOOK_SECRET", "a" * 64)
    end
  end
end
