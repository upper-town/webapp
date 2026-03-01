require "test_helper"

module Admin
  module WebhookConfigs
    class CreateTest < ActiveSupport::TestCase
      let(:described_class) { Create }

      describe "#call" do
        it "creates a webhook config with valid attributes" do
          server = create_server
          form = Admin::WebhookConfigs::Form.new(
            server_id: server.id,
            url: "https://game.company.com/webhooks",
            secret: "a" * 32,
            method: "POST",
            event_types_string: "*"
          )

          result = described_class.call(form)

          assert result.success?
          assert_equal server, result.webhook_config.source
          assert_equal "https://game.company.com/webhooks", result.webhook_config.url
          assert_equal "POST", result.webhook_config.method
          assert_equal ["*"], result.webhook_config.event_types
        end

        it "returns failure when url is blank" do
          server = create_server
          form = Admin::WebhookConfigs::Form.new(
            server_id: server.id,
            url: "",
            secret: "a" * 32,
            method: "POST"
          )

          result = described_class.call(form)

          assert result.failure?
          assert result.errors[:url].present?
        end

        it "returns failure when secret is blank" do
          server = create_server
          form = Admin::WebhookConfigs::Form.new(
            server_id: server.id,
            url: "https://example.com",
            secret: "",
            method: "POST"
          )

          result = described_class.call(form)

          assert result.failure?
          assert result.errors[:secret].present?
        end

        it "returns failure when method is invalid" do
          server = create_server
          form = Admin::WebhookConfigs::Form.new(
            server_id: server.id,
            url: "https://example.com",
            secret: "a" * 32,
            method: "GET"
          )

          result = described_class.call(form)

          assert result.failure?
          assert result.errors[:method].present?
        end
      end
    end
  end
end
