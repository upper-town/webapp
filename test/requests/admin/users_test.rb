require "test_helper"

class Admin::UsersRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/users" do
    it "returns not_found when not authenticated" do
      get(admin_users_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_users_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/users/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      user = create_user

      get(admin_user_path(user))

      assert_response(:success)
    end
  end

  describe "GET /admin/users/:id/edit" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      user = create_user

      get(edit_admin_user_path(user))

      assert_response(:success)
    end
  end

  describe "GET /admin/users/:id/sessions" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      user = create_user

      get(sessions_admin_user_path(user))

      assert_response(:success)
    end
  end

  describe "GET /admin/users/:id/tokens" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      user = create_user

      get(tokens_admin_user_path(user))

      assert_response(:success)
    end
  end

  describe "GET /admin/users/:id/codes" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      user = create_user

      get(codes_admin_user_path(user))

      assert_response(:success)
    end
  end

  describe "PATCH /admin/users/:id" do
    it "updates user and redirects to show" do
      sign_in_as_admin
      user = create_user(
        email_confirmed_at: Time.current,
        locked_at: Time.current,
        locked_reason: "Test lock",
        locked_comment: "Test comment"
      )

      patch(admin_user_path(user), params: {
        admin_users_edit_form: { locked: "0", locked_reason: "", locked_comment: "" }
      })

      assert_redirected_to(admin_user_path(user))
      user.reload
      assert_nil(user.locked_at)
      assert_nil(user.locked_reason)
      assert_nil(user.locked_comment)
    end
  end
end
