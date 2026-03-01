require "test_helper"

class Admin::SessionsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/sessions" do
    it "returns not_found when not authenticated" do
      get(admin_sessions_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_sessions_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/sessions/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      user = create_user
      user_session = Session.create!(
        user:,
        token_digest: TokenGenerator::Session.digest("test-token-123"),
        token_last_four: "1234",
        remote_ip: "127.0.0.1",
        user_agent: "Test",
        expires_at: 1.day.from_now
      )

      get(admin_session_path(user_session))

      assert_response(:success)
    end
  end
end
