require "test_helper"

class Admin::AccountsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/accounts" do
    it "returns not_found when not authenticated" do
      get(admin_accounts_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_accounts_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/accounts/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      account = create_account

      get(admin_account_path(account))

      assert_response(:success)
    end
  end
end
