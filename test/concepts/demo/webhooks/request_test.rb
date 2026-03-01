require "test_helper"

class Demo::Webhooks::RequestTest < ActiveSupport::TestCase
  let(:described_class) { Demo::Webhooks::Request }

  def build_webhook_request(body:, signature:)
    env = Rack::MockRequest.env_for(
      "http://example.com/",
      "REQUEST_METHOD"   => "POST",
      "rack.input"       => StringIO.new(body),
      "HTTP_X_SIGNATURE" => signature
    )
    ActionDispatch::Request.new(env)
  end

  describe "#valid?" do
    it "returns true when signature matches HMAC of body with DEMO_WEBHOOK_SECRET" do
      secret = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      body = [{ "uuid" => "11111111-1111-1111-1111-111111111111", "type" => "test", "data" => {}, "metadata" => {}, "created_at" => "2025-01-01T12:00:00Z" }].to_json
      signature = OpenSSL::HMAC.hexdigest("sha256", secret, body)

      env_with_values("DEMO_WEBHOOK_SECRET" => secret) do
        request = build_webhook_request(body:, signature:)
        instance = described_class.new(request)

        assert(instance.valid?)
      end
    end

    it "returns false when signature does not match" do
      secret = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      body = [{ "uuid" => "11111111-1111-1111-1111-111111111111", "type" => "test", "data" => {}, "metadata" => {}, "created_at" => "2025-01-01T12:00:00Z" }].to_json
      wrong_signature = "0" * 64

      env_with_values("DEMO_WEBHOOK_SECRET" => secret) do
        request = build_webhook_request(body:, signature: wrong_signature)
        instance = described_class.new(request)

        assert_not(instance.valid?)
      end
    end

    it "returns false when X-Signature header is missing" do
      secret = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      body = [].to_json

      env_with_values("DEMO_WEBHOOK_SECRET" => secret) do
        env = Rack::MockRequest.env_for(
          "http://example.com/",
          "REQUEST_METHOD" => "POST",
          "rack.input"     => StringIO.new(body)
        )
        request = ActionDispatch::Request.new(env)
        instance = described_class.new(request)

        assert_not(instance.valid?)
      end
    end
  end

  describe "#webhook_event_hashes" do
    it "parses JSON body and returns array of symbolized event hashes" do
      body = [
        {
          "uuid"       => "11111111-1111-1111-1111-111111111111",
          "type"       => "server_vote.created",
          "data"       => { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          "metadata"   => { "source" => "test" },
          "created_at" => "2025-01-01T12:00:00Z"
        }
      ].to_json
      request = build_webhook_request(body:, signature: "ignored")

      instance = described_class.new(request)
      result = instance.webhook_event_hashes

      assert_equal(
        [
          {
            uuid:       "11111111-1111-1111-1111-111111111111",
            type:       "server_vote.created",
            data:       { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
            metadata:   { "source" => "test" },
            created_at: "2025-01-01T12:00:00Z"
          }
        ],
        result
      )
    end

    it "returns empty array when body is empty JSON array" do
      body = [].to_json
      request = build_webhook_request(body:, signature: "ignored")

      instance = described_class.new(request)
      result = instance.webhook_event_hashes

      assert_equal([], result)
    end
  end

  describe "#request and #request_body" do
    it "exposes request and request_body" do
      body = [].to_json
      request = build_webhook_request(body:, signature: "ignored")
      instance = described_class.new(request)

      assert_equal(request, instance.request)
      assert_equal(body, instance.request_body)
    end
  end
end
