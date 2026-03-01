ApplicationRecordTestFactoryHelper.define(:demo_webhook_event, DemoWebhookEvent,
  uuid: -> { SecureRandom.uuid },
  type: -> { WebhookEvent::SERVER_VOTE_CREATED },
  data: -> { {} },
  metadata: -> { {} }
)
