require "test_helper"

class Admin::TokensRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/tokens" do
    it "returns not_found when not authenticated" do
      get(admin_tokens_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_tokens_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/tokens/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      token = create_token

      get(admin_token_path(token))

      assert_response(:success)
    end
  end
end
