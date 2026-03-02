require "test_helper"

class Admin::ServersQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::ServersQuery }

  describe "#call" do
    it "returns all servers ordered by id desc" do
      server1 = create_server
      server2 = create_server
      server3 = create_server

      assert_equal(
        [
          server3,
          server2,
          server1
        ],
        described_class.new.call
      )
    end

    it "filters by status verified" do
      server1 = create_server(verified_at: Time.current)
      _server2 = create_server(verified_at: nil)

      result = described_class.new(status: "verified").call

      assert_includes(result, server1)
      assert_equal(1, result.count)
    end

    it "filters by status not_verified" do
      _server1 = create_server(verified_at: Time.current)
      server2 = create_server(verified_at: nil)

      result = described_class.new(status: "not_verified").call

      assert_includes(result, server2)
      assert_equal(1, result.count)
    end

    it "filters by status archived" do
      server1 = create_server(archived_at: Time.current)
      _server2 = create_server(archived_at: nil)

      result = described_class.new(status: "archived").call

      assert_includes(result, server1)
      assert_equal(1, result.count)
    end

    it "filters by status marked_for_deletion" do
      server1 = create_server(marked_for_deletion_at: Time.current)
      _server2 = create_server(marked_for_deletion_at: nil)

      result = described_class.new(status: "marked_for_deletion").call

      assert_includes(result, server1)
      assert_equal(1, result.count)
    end

    it "filters by multiple statuses with OR logic" do
      server_verified = create_server(verified_at: Time.current, archived_at: nil)
      server_archived = create_server(verified_at: nil, archived_at: Time.current)
      _server_other = create_server(verified_at: nil, archived_at: nil)

      result = described_class.new(status: %w[verified archived]).call

      assert_includes(result, server_verified)
      assert_includes(result, server_archived)
      assert_not_includes(result, _server_other)
      assert_equal(2, result.count)
    end

    it "filters by country_code" do
      server_us = create_server(country_code: "US")
      _server_de = create_server(country_code: "DE")

      result = described_class.new(country_code: "US").call

      assert_includes(result, server_us)
      assert_equal(1, result.count)
    end

    it "filters by multiple country_codes" do
      server_us = create_server(country_code: "US")
      server_de = create_server(country_code: "DE")
      _server_br = create_server(country_code: "BR")

      result = described_class.new(country_codes: %w[US DE]).call

      assert_includes(result, server_us)
      assert_includes(result, server_de)
      assert_not_includes(result, _server_br)
      assert_equal(2, result.count)
    end

    it "filters by game_ids" do
      game1 = create_game
      game2 = create_game
      game3 = create_game
      server1 = create_server(game: game1)
      server2 = create_server(game: game2)
      _server3 = create_server(game: game3)

      result = described_class.new(game_ids: [game1.id, game2.id]).call

      assert_includes(result, server1)
      assert_includes(result, server2)
      assert_not_includes(result, _server3)
      assert_equal(2, result.count)
    end

    it "applies both status and country_code when provided" do
      server = create_server(verified_at: Time.current, country_code: "US")
      _other = create_server(verified_at: Time.current, country_code: "DE")
      _unverified = create_server(verified_at: nil, country_code: "US")

      result = described_class.new(status: "verified", country_code: "US").call

      assert_includes(result, server)
      assert_equal(1, result.count)
    end

    it "scopes to relation when provided" do
      game1 = create_game
      game2 = create_game
      server1 = create_server(game: game1)
      server2 = create_server(game: game2)

      result = described_class.new(relation: game1.servers).call

      assert_includes(result, server1)
      assert_not_includes(result, server2)
      assert_equal(1, result.count)
    end

    it "sorts by id asc when sort=id and sort_dir=asc" do
      server1 = create_server
      server2 = create_server
      server3 = create_server

      result = described_class.new(sort: "id", sort_dir: "asc").call

      assert_equal([server1, server2, server3], result.to_a)
    end

    it "sorts by id desc when sort=id and sort_dir=desc" do
      server1 = create_server
      server2 = create_server
      server3 = create_server

      result = described_class.new(sort: "id", sort_dir: "desc").call

      assert_equal([server3, server2, server1], result.to_a)
    end

    it "sorts by name when sort=name" do
      server_a = create_server(name: "Alpha Server")
      server_b = create_server(name: "Beta Server")
      server_c = create_server(name: "Gamma Server")

      result_asc = described_class.new(sort: "name", sort_dir: "asc").call
      result_desc = described_class.new(sort: "name", sort_dir: "desc").call

      assert_equal([server_a, server_b, server_c], result_asc.to_a)
      assert_equal([server_c, server_b, server_a], result_desc.to_a)
    end

    it "sorts by game name when sort=game" do
      game_a = create_game(name: "Alpha Game")
      game_b = create_game(name: "Beta Game")
      server_a = create_server(game: game_a)
      server_b = create_server(game: game_b)

      result = described_class.new(sort: "game", sort_dir: "asc").call

      assert_equal([server_a, server_b], result.to_a)
    end

    it "combines sort with status and country filters" do
      server1 = create_server(verified_at: Time.current, country_code: "US", name: "Zebra")
      server2 = create_server(verified_at: Time.current, country_code: "US", name: "Alpha")

      result = described_class.new(
        status: "verified",
        country_code: "US",
        sort: "name",
        sort_dir: "asc"
      ).call

      assert_equal([server2, server1], result.to_a)
    end
  end
end
