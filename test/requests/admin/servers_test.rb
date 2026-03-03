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

    it "responds with success with filter params and preserves them with search" do
      sign_in_as_admin
      create_server(verified_at: Time.current, country_code: "US")

      get(admin_servers_path, params: { status: ["verified"], country_codes: ["US"], q: "test" })

      assert_response(:success)
    end

    it "sorts by column when sort and sort_dir params provided" do
      sign_in_as_admin
      create_server(name: "Alpha")
      create_server(name: "Beta")
      create_server(name: "Gamma")

      get(admin_servers_path, params: { sort_key: "name", sort_dir: "asc" })

      assert_response(:success)
      assert_select "th a.admin-table-sort-link[href*='sort_key=name']"
    end

    it "preserves sort params with filters and search" do
      sign_in_as_admin
      create_server(verified_at: Time.current, country_code: "US", name: "Test Server")

      get(admin_servers_path, params: {
        status: ["verified"],
        country_codes: ["US"],
        q: "Test",
        sort_key: "name",
        sort_dir: "asc"
      })

      assert_response(:success)
      assert_select "th a.admin-table-sort-link[href*='sort_key=name']"
      assert_select "input[name=sort_key][value=name]"
      assert_select "input[name=sort_dir][value=asc]"
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

  describe "PATCH /admin/servers/:id" do
    it "updates server and redirects to show" do
      sign_in_as_admin
      server = create_server(description: "Original description")

      patch(admin_server_path(server), params: {
        server: {
          game_id: server.game_id,
          country_code: server.country_code,
          name: server.name,
          site_url: server.site_url,
          description: "Updated description",
          info: server.info,
          banner_image_approved: server.banner_image_approved?.to_s
        }
      })

      assert_redirected_to(admin_server_path(server))
      assert_equal("Updated description", server.reload.description)
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
