require "test_helper"

class Admin::WebhookEventsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::WebhookEventsQuery }

  describe "#call" do
    it "returns all webhook events ordered by id desc" do
      event1 = create_webhook_event
      event2 = create_webhook_event
      event3 = create_webhook_event

      assert_equal(
        [
          event3,
          event2,
          event1
        ],
        described_class.new.call
      )
    end

    it "filters by webhook_config_id when provided" do
      config1 = create_webhook_config
      config2 = create_webhook_config
      event1 = create_webhook_event(config: config1)
      create_webhook_event(config: config2)
      event3 = create_webhook_event(config: config1)

      result = described_class.new(webhook_config_id: config1.id).call

      assert_equal([event3, event1], result)
    end
  end
end
