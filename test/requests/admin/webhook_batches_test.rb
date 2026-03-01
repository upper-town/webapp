require "test_helper"

class Admin::WebhookBatchesRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/webhook_batches" do
    it "returns not_found when not authenticated" do
      get(admin_webhook_batches_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_webhook_batches_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/webhook_batches/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      webhook_batch = create_webhook_batch

      get(admin_webhook_batch_path(webhook_batch))

      assert_response(:success)
    end
  end
end
