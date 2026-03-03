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

  describe "POST /admin/feature_flags" do
    it "creates feature flag and redirects to show" do
      sign_in_as_admin
      flag_name = "test_flag_#{SecureRandom.hex(8)}"
      comment = "Test flag"

      assert_difference(-> { FeatureFlag.count }, 1) do
        post(admin_feature_flags_path, params: {
          feature_flag: { name: flag_name, value: "true", comment: }
        })
      end

      assert_redirected_to(%r{/admin/feature_flags/\d+})
      created = FeatureFlag.find_by!(name: flag_name)
      assert_equal("true", created.value)
      assert_equal(comment, created.comment)
    end
  end

  describe "PATCH /admin/feature_flags/:id" do
    it "updates feature flag and redirects to show" do
      sign_in_as_admin
      feature_flag = create_feature_flag(value: "true", comment: "Original")

      patch(admin_feature_flag_path(feature_flag), params: {
        feature_flag: {
          name: feature_flag.name,
          value: "false",
          comment: "Updated comment"
        }
      })

      assert_redirected_to(admin_feature_flag_path(feature_flag))
      feature_flag.reload
      assert_equal("false", feature_flag.value)
      assert_equal("Updated comment", feature_flag.comment)
    end
  end
end
