require "test_helper"

class Admin::AdminRolesRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/roles" do
    it "returns not_found when not authenticated" do
      get(admin_admin_roles_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_admin_roles_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/roles/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_role = create_admin_role

      get(admin_admin_role_path(admin_role))

      assert_response(:success)
    end
  end

  describe "GET /admin/roles/:id/edit" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_role = create_admin_role

      get(edit_admin_admin_role_path(admin_role))

      assert_response(:success)
    end
  end
end
