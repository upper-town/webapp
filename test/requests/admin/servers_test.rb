require "test_helper"

class Admin::ServersRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/servers" do
    it "returns not_found when not authenticated" do
      get(admin_servers_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_servers_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/servers/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      server = create_server

      get(admin_server_path(server))

      assert_response(:success)
    end
  end

  describe "GET /admin/servers/:id/edit" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      server = create_server

      get(edit_admin_server_path(server))

      assert_response(:success)
    end
  end
end
