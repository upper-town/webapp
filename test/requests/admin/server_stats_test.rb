require "test_helper"

class Admin::ServerStatsRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/server_stats" do
    it "returns not_found when not authenticated" do
      get(admin_server_stats_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_server_stats_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/server_stats/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      server_stat = create_server_stat

      get(admin_server_stat_path(server_stat))

      assert_response(:success)
    end
  end
end
