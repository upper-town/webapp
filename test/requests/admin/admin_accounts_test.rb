require "test_helper"

class Admin::AdminAccountsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/admin_accounts" do
    it "returns not_found when not authenticated" do
      get(admin_admin_accounts_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_admin_accounts_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_accounts/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_account = create_admin_account

      get(admin_admin_account_path(admin_account))

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_accounts/:id/edit" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_account = create_admin_account

      get(edit_admin_admin_account_path(admin_account))

      assert_response(:success)
    end
  end
end
