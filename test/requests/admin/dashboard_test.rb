require "test_helper"

class Admin::DashboardRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin" do
    it "returns not_found when not authenticated (constraint blocks route)" do
      get(admin_root_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_root_path)

      assert_response(:success)
    end
  end
end
