require "test_helper"

class Demo::WebhookEvents::CreateTest < ActiveSupport::TestCase
  let(:described_class) { Demo::WebhookEvents::Create }

  describe "#call" do
    it "inserts webhook event hashes when present" do
      hashes = [
        {
          uuid:       SecureRandom.uuid,
          type:       WebhookEvent::SERVER_VOTE_CREATED,
          data:       {},
          metadata:   {},
          created_at: "2025-01-01T12:00:00Z"
        }
      ]

      assert_difference(-> { DemoWebhookEvent.count }, 1) do
        described_class.call(hashes)
      end

      event = DemoWebhookEvent.last
      assert_equal hashes.first[:uuid], event.uuid
      assert_equal hashes.first[:type], event.type
      assert_equal hashes.first[:data], event.data
      assert_equal hashes.first[:metadata], event.metadata
    end

    it "does nothing when webhook_event_hashes is blank" do
      assert_no_difference(-> { DemoWebhookEvent.count }) do
        described_class.call([])
      end

      assert_no_difference(-> { DemoWebhookEvent.count }) do
        described_class.call(nil)
      end
    end

    it "inserts multiple events" do
      hashes = 3.times.map do
        {
          uuid:       SecureRandom.uuid,
          type:       WebhookEvent::SERVER_VOTE_CREATED,
          data:       {},
          metadata:   {},
          created_at: "2025-01-01T12:00:00Z"
        }
      end

      assert_difference(-> { DemoWebhookEvent.count }, 3) do
        described_class.call(hashes)
      end
    end
  end
end
