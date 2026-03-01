require "test_helper"

module Inside
  class WebhookConfigsRequestTest < ActionDispatch::IntegrationTest
    describe "GET /i/servers/:server_id/webhook_configs" do
      it "redirects to sign in when not authenticated" do
        server = create_server
        account = create_account
        create_server_account(server:, account:)

        get(inside_server_webhook_configs_path(server))

        assert_redirected_to(users_sign_in_url)
      end

      it "returns success when authenticated and account owns server" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        create_server_account(server:, account:)
        sign_in_as_user(user)

        get(inside_server_webhook_configs_path(server))

        assert_response(:success)
      end

      it "returns not_found when account does not own server" do
        user = create_user(email_confirmed_at: Time.current)
        create_account(user:)
        server = create_server
        sign_in_as_user(user)

        get(inside_server_webhook_configs_path(server))

        assert_response(:not_found)
      end
    end

    describe "GET /i/servers/:server_id/webhook_configs/new" do
      it "returns success when authenticated and account owns server" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        create_server_account(server:, account:)
        sign_in_as_user(user)

        get(new_inside_server_webhook_config_path(server))

        assert_response(:success)
      end
    end

    describe "POST /i/servers/:server_id/webhook_configs" do
      it "re-renders new with errors when form is invalid" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        create_server_account(server:, account:)
        sign_in_as_user(user)

        assert_no_difference(-> { WebhookConfig.count }) do
          post(
            inside_server_webhook_configs_path(server),
            params: {
              webhook_config: {
                url: "",
                secret: "",
                method: "POST",
                event_types_string: "*"
              }
            }
          )
        end

        assert_response(:unprocessable_entity)
      end

      it "returns bad_request when webhook_config params are missing" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        create_server_account(server:, account:)
        sign_in_as_user(user)

        assert_no_difference(-> { WebhookConfig.count }) do
          post(inside_server_webhook_configs_path(server), params: {})
        end

        assert_response(:bad_request)
      end

      it "creates webhook config when valid" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        create_server_account(server:, account:)
        sign_in_as_user(user)

        assert_difference(-> { WebhookConfig.count }, 1) do
          post(
            inside_server_webhook_configs_path(server),
            params: {
              webhook_config: {
                url: "https://example.com/webhooks",
                secret: "a" * 32,
                method: "POST",
                event_types_string: "*"
              }
            }
          )
        end

        assert_redirected_to(inside_server_webhook_config_path(server, WebhookConfig.last))
        assert_equal(server, WebhookConfig.last.source)
      end
    end

    describe "GET /i/servers/:server_id/webhook_configs/:id" do
      it "returns success when authenticated and account owns server" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        create_server_account(server:, account:)
        webhook_config = create_webhook_config(source: server)
        sign_in_as_user(user)

        get(inside_server_webhook_config_path(server, webhook_config))

        assert_response(:success)
      end

      it "returns not_found when webhook config belongs to different server" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        other_server = create_server
        create_server_account(server:, account:)
        webhook_config = create_webhook_config(source: other_server)
        sign_in_as_user(user)

        get(inside_server_webhook_config_path(server, webhook_config))

        assert_response(:not_found)
      end
    end

    describe "GET /i/servers/:server_id/webhook_configs/:id/edit" do
      it "returns success when authenticated and account owns server" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        create_server_account(server:, account:)
        webhook_config = create_webhook_config(source: server)
        sign_in_as_user(user)

        get(edit_inside_server_webhook_config_path(server, webhook_config))

        assert_response(:success)
      end
    end

    describe "PATCH /i/servers/:server_id/webhook_configs/:id" do
      it "returns not_found when webhook config belongs to different server" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        other_server = create_server
        create_server_account(server:, account:)
        webhook_config = create_webhook_config(source: other_server)
        sign_in_as_user(user)

        patch(
          inside_server_webhook_config_path(server, webhook_config),
          params: {
            webhook_config: {
              url: "https://new.example.com/webhooks",
              method: "POST",
              event_types_string: "server_vote.*"
            }
          }
        )

        assert_response(:not_found)
        assert_equal("https://game.company.com", webhook_config.reload.url)
      end

      it "re-renders edit with errors when form is invalid" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        create_server_account(server:, account:)
        webhook_config = create_webhook_config(source: server, url: "https://old.example.com")
        sign_in_as_user(user)

        patch(
          inside_server_webhook_config_path(server, webhook_config),
          params: {
            webhook_config: {
              url: "",
              method: "POST",
              event_types_string: "server_vote.*"
            }
          }
        )

        assert_response(:unprocessable_entity)
        assert_equal("https://old.example.com", webhook_config.reload.url)
      end

      it "updates webhook config when valid" do
        user = create_user(email_confirmed_at: Time.current)
        account = create_account(user:)
        server = create_server
        create_server_account(server:, account:)
        webhook_config = create_webhook_config(source: server, url: "https://old.example.com")
        sign_in_as_user(user)

        patch(
          inside_server_webhook_config_path(server, webhook_config),
          params: {
            webhook_config: {
              url: "https://new.example.com/webhooks",
              method: "POST",
              event_types_string: "server_vote.*"
            }
          }
        )

        assert_redirected_to(inside_server_webhook_config_path(server, webhook_config))
        assert_equal("https://new.example.com/webhooks", webhook_config.reload.url)
        assert_equal(["server_vote.*"], webhook_config.event_types)
      end
    end
  end
end
