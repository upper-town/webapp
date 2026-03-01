require "test_helper"

class Admin::ServerAccountsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/server_accounts" do
    it "returns not_found when not authenticated" do
      get(admin_server_accounts_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_server_accounts_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/server_accounts/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      server_account = create_server_account

      get(admin_server_account_path(server_account))

      assert_response(:success)
    end
  end
end
