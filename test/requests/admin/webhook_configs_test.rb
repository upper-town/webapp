require "test_helper"

class Admin::WebhookConfigsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/webhook_configs" do
    it "returns not_found when not authenticated" do
      get(admin_webhook_configs_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_webhook_configs_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/webhook_configs/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      webhook_config = create_webhook_config

      get(admin_webhook_config_path(webhook_config))

      assert_response(:success)
    end
  end

  describe "GET /admin/webhook_configs/new" do
    it "responds with success when authenticated" do
      sign_in_as_admin

      get(new_admin_webhook_config_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/webhook_configs/:id/edit" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      webhook_config = create_webhook_config

      get(edit_admin_webhook_config_path(webhook_config))

      assert_response(:success)
    end
  end

  describe "GET /admin/webhook_configs/:id/batches" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      webhook_config = create_webhook_config

      get(batches_admin_webhook_config_path(webhook_config))

      assert_response(:success)
    end
  end

  describe "GET /admin/webhook_configs/:id/events" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      webhook_config = create_webhook_config

      get(events_admin_webhook_config_path(webhook_config))

      assert_response(:success)
    end
  end
end
