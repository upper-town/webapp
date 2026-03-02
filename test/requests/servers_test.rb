require "test_helper"

class ServersRequestTest < ActionDispatch::IntegrationTest
  describe "#index" do
    it "responds with success" do
      get(servers_path)

      assert_response(:success)
    end

    it "responds with success when filtering by game" do
      game = create_game

      get(servers_path(game_ids: [game.id]))

      assert_response(:success)
    end

    it "responds with success when filtering by multiple games" do
      game1 = create_game
      game2 = create_game

      get(servers_path(game_ids: [game1.id, game2.id]))

      assert_response(:success)
    end

    it "responds with success when filtering by country_codes" do
      get(servers_path(country_codes: ["US"]))

      assert_response(:success)
    end

    it "responds with success when filtering by multiple country_codes" do
      get(servers_path(country_codes: ["US", "CA", "MX"]))

      assert_response(:success)
    end

    it "responds with not_found when game_ids contains invalid id" do
      get(servers_path(game_ids: [999_999]))

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
