require "test_helper"

class Admin::ServerVerifiedAccountsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/servers/:id/verified_accounts" do
    it "returns not_found when not authenticated" do
      server = create_server

      get(verified_accounts_admin_server_path(server))

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin
      server = create_server

      get(verified_accounts_admin_server_path(server))

      assert_response(:success)
    end

    it "responds with success with search and sort params" do
      sign_in_as_admin
      server = create_server
      account = create_account
      create_server_account(server:, account:, verified_at: Time.current)

      get(verified_accounts_admin_server_path(server), params: {
        q: account.user.email,
        sort_key: "email",
        sort_dir: "asc"
      })

      assert_response(:success)
    end
  end
end
