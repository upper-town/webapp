require "test_helper"

class Admin::AdminUsersRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/admin_users" do
    it "returns not_found when not authenticated" do
      get(admin_admin_users_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_admin_users_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_users/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_user = create_admin_user

      get(admin_admin_user_path(admin_user))

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_users/:id/edit" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_user = create_admin_user

      get(edit_admin_admin_user_path(admin_user))

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_users/:id/sessions" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_user = create_admin_user

      get(sessions_admin_admin_user_path(admin_user))

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_users/:id/tokens" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_user = create_admin_user

      get(tokens_admin_admin_user_path(admin_user))

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_users/:id/codes" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_user = create_admin_user

      get(codes_admin_admin_user_path(admin_user))

      assert_response(:success)
    end
  end
end
