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

  describe "POST /admin/webhook_configs" do
    it "creates webhook config and redirects to show" do
      sign_in_as_admin
      server = create_server
      url = "https://server-#{SecureRandom.hex(4)}.upper.town/webhook"

      assert_difference(-> { WebhookConfig.count }, 1) do
        post(admin_webhook_configs_path, params: {
          webhook_config: {
            server_id: server.id,
            url:,
            secret: "secret123",
            method: "POST",
            event_types_string: "server.updated",
            disabled: "0"
          }
        })
      end

      assert_redirected_to(%r{/admin/webhook_configs/\d+})
      created = WebhookConfig.find_by!(source: server, url:)
      assert_equal(server, created.source)
      assert_equal(url, created.url)
      assert_equal("POST", created.method)
      assert_includes(created.event_types, "server.updated")
      assert_nil(created.disabled_at)
    end
  end

  describe "PATCH /admin/webhook_configs/:id" do
    it "updates webhook config and redirects to show" do
      sign_in_as_admin
      server = create_server
      webhook_config = create_webhook_config(source: server)
      assert_nil(webhook_config.disabled_at, "precondition: config starts enabled")

      patch(admin_webhook_config_path(webhook_config), params: {
        webhook_config: {
          server_id: server.id,
          url: webhook_config.url,
          method: webhook_config.method,
          event_types_string: webhook_config.event_types.join(", "),
          disabled: "1"
        }
      })

      assert_redirected_to(admin_webhook_config_path(webhook_config))
      assert_not_nil(webhook_config.reload.disabled_at)
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
