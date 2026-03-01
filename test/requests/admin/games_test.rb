require "test_helper"

class Admin::GamesRequestTest < ActionDispatch::IntegrationTest
  describe "GET /admin/games" do
    it "returns not_found when not authenticated" do
      get(admin_games_path)

      assert_response(:not_found)
    end

    it "responds with success when authenticated" do
      sign_in_as_admin

      get(admin_games_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/games/:id" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      game = create_game

      get(admin_game_path(game))

      assert_response(:success)
    end
  end

  describe "GET /admin/games/new" do
    it "responds with success when authenticated" do
      sign_in_as_admin

      get(new_admin_game_path)

      assert_response(:success)
    end
  end

  describe "GET /admin/games/:id/edit" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      game = create_game

      get(edit_admin_game_path(game))

      assert_response(:success)
    end
  end

  describe "GET /admin/games/:id/servers" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      game = create_game

      get(servers_admin_game_path(game))

      assert_response(:success)
    end
  end
end
