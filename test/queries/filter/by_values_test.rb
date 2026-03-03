require "test_helper"

class Filter::ByValuesTest < ActiveSupport::TestCase
  let(:described_class) { Admin::ServersFilterQuery }

  describe "by_values mixin" do
    it "returns all records when country_codes is blank" do
      create_server(country_code: "US")
      create_server(country_code: "DE")

      relation = Server.all
      result = described_class.call(relation, country_codes: nil)

      assert_equal(2, result.count)
    end

    it "filters by country_codes when provided" do
      server_us = create_server(country_code: "US")
      server_de = create_server(country_code: "DE")
      server_br = create_server(country_code: "BR")

      relation = Server.all
      result = described_class.call(relation, country_codes: %w[US DE])

      assert_includes(result, server_us)
      assert_includes(result, server_de)
      assert_not_includes(result, server_br)
      assert_equal(2, result.count)
    end

    it "handles single country_code" do
      server_us = create_server(country_code: "US")
      create_server(country_code: "DE")

      relation = Server.all
      result = described_class.call(relation, country_codes: "US")

      assert_includes(result, server_us)
      assert_equal(1, result.count)
    end

    it "returns all records when game_ids is blank" do
      create_server
      create_server

      relation = Server.all
      result = described_class.call(relation, game_ids: nil)

      assert_equal(2, result.count)
    end

    it "filters by game_ids when provided" do
      game1 = create_game
      game2 = create_game
      game3 = create_game
      server1 = create_server(game: game1)
      server2 = create_server(game: game2)
      _server3 = create_server(game: game3)

      relation = Server.all
      result = described_class.call(relation, game_ids: [game1.id, game2.id])

      assert_includes(result, server1)
      assert_includes(result, server2)
      assert_equal(2, result.count)
    end

    it "handles single game_id as string" do
      game = create_game
      server = create_server(game:)
      create_server

      relation = Server.all
      result = described_class.call(relation, game_ids: game.id.to_s)

      assert_includes(result, server)
      assert_equal(1, result.count)
    end
  end
end
