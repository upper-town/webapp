require "test_helper"

class ServersRequestTest < ActionDispatch::IntegrationTest
  describe "#index" do
    it "responds with success" do
      get(servers_path)

      assert_response(:success)
    end

    it "responds with success when filtering by game" do
      game = create_game

      get(servers_path(game_id: game.id))

      assert_response(:success)
    end

    it "responds with not_found when game_id is invalid" do
      get(servers_path(game_id: 999_999))

      assert_response(:not_found)
    end
  end

  describe "#show" do
    it "responds with success for existing server" do
      server = create_server

      get(server_path(server))

      assert_response(:success)
    end
  end
end
