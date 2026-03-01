ApplicationRecordTestFactoryHelper.define(:webhook_config, WebhookConfig,
  source: -> { build_server },
  url: -> { "https://game.company.com" },
  secret: -> { "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
)
