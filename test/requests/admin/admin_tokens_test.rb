require "test_helper"

class Admin::AdminTokensRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/admin_tokens" do
    it "returns not_found when not authenticated" do
      get(admin_admin_tokens_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_admin_tokens_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_tokens/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_token = create_admin_token

      get(admin_admin_token_path(admin_token))

      assert_response(:success)
    end
  end
end
