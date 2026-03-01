require "test_helper"

class Admin::FeatureFlagsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/feature_flags" do
    it "returns not_found when not authenticated" do
      get(admin_feature_flags_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_feature_flags_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/feature_flags/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      feature_flag = create_feature_flag

      get(admin_feature_flag_path(feature_flag))

      assert_response(:success)
    end
  end

  describe "GET /admin/feature_flags/new" do
    it "responds with success when authenticated" do
      sign_in_as_admin

      get(new_admin_feature_flag_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/feature_flags/:id/edit" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      feature_flag = create_feature_flag

      get(edit_admin_feature_flag_path(feature_flag))

      assert_response(:success)
    end
  end
end
