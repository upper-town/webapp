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

  describe "POST /admin/games" do
    it "creates game and redirects to show" do
      sign_in_as_admin
      slug = "new-test-game-#{SecureRandom.hex(6)}"
      name = "New Test Game"
      description = "A new game"

      assert_difference(-> { Game.count }, 1) do
        post(admin_games_path, params: {
          game: {
            name:,
            slug:,
            site_url: "https://minecraft.net",
            description:,
            info: ""
          }
        })
      end

      assert_redirected_to(%r{/admin/games/\d+})
      created = Game.find_by!(slug:)
      assert_equal(name, created.name)
      assert_equal(slug, created.slug)
      assert_equal("https://minecraft.net", created.site_url)
      assert_equal(description, created.description)
    end
  end

  describe "PATCH /admin/games/:id" do
    it "updates game and redirects to show" do
      sign_in_as_admin
      game = create_game(description: "Original")

      patch(admin_game_path(game), params: {
        game: {
          name: game.name,
          slug: game.slug,
          site_url: game.site_url,
          description: "Updated description",
          info: game.info
        }
      })

      assert_redirected_to(admin_game_path(game))
      assert_equal("Updated description", game.reload.description)
    end
  end

  describe "GET /admin/games/:id/servers" do
    it "responds with success when authenticated" do
      sign_in_as_admin
      game = create_game

      get(servers_admin_game_path(game))

      assert_response(:success)
    end

    it "responds with success with filter params and preserves them with search" do
      sign_in_as_admin
      game = create_game
      create_server(game:, verified_at: Time.current, country_code: "US")

      get(servers_admin_game_path(game), params: { status: ["verified"], country_codes: ["US"], q: "test" })

      assert_response(:success)
    end
  end
end
