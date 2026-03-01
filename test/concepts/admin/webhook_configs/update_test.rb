require "test_helper"

module Admin
  module WebhookConfigs
    class UpdateTest < ActiveSupport::TestCase
      let(:described_class) { Update }

      describe "#call" do
        it "updates a webhook config with valid attributes" do
          webhook_config = create_webhook_config(url: "https://old.example.com", method: "POST")
          form = Admin::WebhookConfigs::Form.new(
            webhook_config:,
            url: "https://new.example.com",
            method: "PUT"
          )

          result = described_class.call(webhook_config, form)

          assert result.success?
          assert_equal "https://new.example.com", result.webhook_config.url
          assert_equal "PUT", result.webhook_config.method
        end

        it "can disable the webhook config" do
          webhook_config = create_webhook_config(disabled_at: nil)
          form = Admin::WebhookConfigs::Form.new(
            webhook_config:,
            url: webhook_config.url,
            method: webhook_config.method,
            disabled: true
          )

          result = described_class.call(webhook_config, form)

          assert result.success?
          assert result.webhook_config.disabled?
        end

        it "returns failure when url is blank" do
          webhook_config = create_webhook_config
          form = Admin::WebhookConfigs::Form.new(
            webhook_config:,
            url: "",
            method: webhook_config.method
          )

          result = described_class.call(webhook_config, form)

          assert result.failure?
          assert result.errors[:url].present?
        end
      end
    end
  end
end
