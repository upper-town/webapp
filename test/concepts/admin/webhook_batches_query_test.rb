# frozen_string_literal: true

require "test_helper"

class Admin::WebhookBatchesQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::WebhookBatchesQuery }

  describe "#call" do
    it "returns all webhook batches ordered by id desc" do
      batch1 = create_webhook_batch
      batch2 = create_webhook_batch
      batch3 = create_webhook_batch

      assert_equal(
        [batch3, batch2, batch1],
        described_class.new.call
      )
    end

    it "filters by webhook_config_id when provided" do
      config = create_webhook_config
      batch1 = create_webhook_batch(config: config)
      batch2 = create_webhook_batch
      batch3 = create_webhook_batch(config: config)

      result = described_class.new(webhook_config_id: config.id).call

      assert_equal([batch3, batch1], result)
    end
  end
end
