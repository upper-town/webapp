require "test_helper"

class Admin::AdminCodesRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/admin_codes" do
    it "returns not_found when not authenticated" do
      get(admin_admin_codes_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_admin_codes_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/admin_codes/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      admin_code = create_admin_code

      get(admin_admin_code_path(admin_code))

      assert_response(:success)
    end
  end
end
