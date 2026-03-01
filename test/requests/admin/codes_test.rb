require "test_helper"

class Admin::CodesRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/codes" do
    it "returns not_found when not authenticated" do
      get(admin_codes_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_codes_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/codes/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      code = create_code

      get(admin_code_path(code))

      assert_response(:success)
    end
  end
end
