require "test_helper"

class Admin::AccountVerifiedServersRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/accounts/:id/verified_servers" do
    it "returns not_found when not authenticated" do
      account = create_account

      get(verified_servers_admin_account_path(account))

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin
      account = create_account

      get(verified_servers_admin_account_path(account))

      assert_response(:success)
    end
  end
end
