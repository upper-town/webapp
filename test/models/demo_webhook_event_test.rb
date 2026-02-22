# frozen_string_literal: true

require "test_helper"

class DemoWebhookEventTest < ActiveSupport::TestCase
  let(:described_class) { DemoWebhookEvent }

  it "creates and persists a record" do
    demo_webhook_event = create_demo_webhook_event(
      type: WebhookEvent::SERVER_VOTE_CREATED,
      data: { "server_id" => "123" },
      metadata: { "source" => "test" }
    )

    assert(demo_webhook_event.persisted?)
    assert_equal(WebhookEvent::SERVER_VOTE_CREATED, demo_webhook_event.type)
    assert_equal({ "server_id" => "123" }, demo_webhook_event.data)
    assert_equal({ "source" => "test" }, demo_webhook_event.metadata)
    assert_not_nil(demo_webhook_event.created_at)
    assert_not_nil(demo_webhook_event.updated_at)
  end
end
