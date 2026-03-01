require "test_helper"

class ServerVotesRequestTest < ActionDispatch::IntegrationTest
  describe "#show" do
    it "responds with success for existing vote" do
      server_vote = create_server_vote

      get(server_vote_path(server_vote))

      assert_response(:success)
    end
  end

  describe "#new" do
    it "responds with success" do
      server = create_server

      get(new_server_vote_path(server))

      assert_response(:success)
    end

    it "prefills reference from URL params" do
      server = create_server

      get(new_server_vote_path(server, reference: "campaign-123"))

      assert_response(:success)
      assert_select "input[name='server_vote[reference]'][value='campaign-123']", 1
    end
  end
end
