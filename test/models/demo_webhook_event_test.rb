# frozen_string_literal: true

require "test_helper"

class DemoWebhookEventTest < ActiveSupport::TestCase
  let(:described_class) { DemoWebhookEvent }

  describe "persistence" do
    it "creates and persists a record" do
      event = create_demo_webhook_event(
        uuid: SecureRandom.uuid,
        type: WebhookEvent::SERVER_VOTE_CREATED,
        data: { "server_id" => "123" },
        metadata: { "source" => "test" }
      )

      assert(event.persisted?)
      assert_equal(WebhookEvent::SERVER_VOTE_CREATED, event.type)
      assert_equal({ "server_id" => "123" }, event.data)
      assert_equal({ "source" => "test" }, event.metadata)
      assert_not_nil(event.created_at)
      assert_not_nil(event.updated_at)
    end

    it "uses default empty hashes for data and metadata" do
      event = create_demo_webhook_event

      assert_equal({}, event.data)
      assert_equal({}, event.metadata)
    end
  end

  describe "uniqueness" do
    it "enforces unique uuid" do
      uuid = SecureRandom.uuid
      create_demo_webhook_event(uuid:)

      assert_raises(ActiveRecord::RecordNotUnique) do
        create_demo_webhook_event(uuid:)
      end
    end
  end

  describe ".insert_all" do
    it "bulk inserts events from webhook_event_hashes" do
      hashes = [
        {
          uuid: SecureRandom.uuid,
          type: WebhookEvent::SERVER_VOTE_CREATED,
          data: { "a" => 1 },
          metadata: {},
          created_at: Time.current
        },
        {
          uuid: SecureRandom.uuid,
          type: WebhookEvent::SERVER_VOTE_CREATED,
          data: { "b" => 2 },
          metadata: { "key" => "value" },
          created_at: Time.current
        }
      ]

      result = described_class.insert_all(hashes)

      assert_equal(2, result.length)
      assert_equal(2, described_class.count)

      events = described_class.order(:created_at)
      assert_equal(hashes[0][:uuid], events[0].uuid)
      assert_equal(hashes[0][:data], events[0].data)
      assert_equal(hashes[1][:metadata], events[1].metadata)
    end
  end
end
