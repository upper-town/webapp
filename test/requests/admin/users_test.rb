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
end
