require "test_helper"

class Admin::WebhookEventsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/webhook_events" do
    it "returns not_found when not authenticated" do
      get(admin_webhook_events_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_webhook_events_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/webhook_events/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      webhook_event = create_webhook_event

      get(admin_webhook_event_path(webhook_event))

      assert_response(:success)
    end
  end
end
