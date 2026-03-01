require "test_helper"

class Admin::AdminSessionsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/admin_sessions" do
    it "returns not_found when not authenticated" do
      get(admin_admin_sessions_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_admin_sessions_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_sessions/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_session = create_admin_session

      get(admin_admin_session_path(admin_session))

      assert_response(:success)
    end
  end
end
