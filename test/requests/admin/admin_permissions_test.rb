require "test_helper"

class Admin::AdminPermissionsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/permissions" do
    it "returns not_found when not authenticated" do
      get(admin_admin_permissions_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_admin_permissions_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/permissions/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_permission = create_admin_permission

      get(admin_admin_permission_path(admin_permission))

      assert_response(:success)
    end
  end
end
