require "test_helper"

class Admin::ServerVotesRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/server_votes" do
    it "returns not_found when not authenticated" do
      get(admin_server_votes_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_server_votes_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/server_votes/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      server_vote = create_server_vote

      get(admin_server_vote_path(server_vote))

      assert_response(:success)
    end
  end
end
