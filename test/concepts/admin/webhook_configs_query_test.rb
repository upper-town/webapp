require "test_helper"

class Admin::WebhookConfigsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::WebhookConfigsQuery }

  describe "#call" do
    it "returns all webhook configs ordered by id desc" do
      config1 = create_webhook_config
      config2 = create_webhook_config
      config3 = create_webhook_config

      assert_equal(
        [
          config3,
          config2,
          config1
        ],
        described_class.new.call
      )
    end
  end
end
