require "test_helper"

class Admin::ServerStatsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::ServerStatsQuery }

  describe "#call" do
    it "returns all server stats ordered by reference_date desc, id desc" do
      ss1 = create_server_stat
      ss2 = create_server_stat
      ss3 = create_server_stat

      result = described_class.new.call
      assert_equal(3, result.size)
      assert_equal([ss3, ss2, ss1], result.sort_by { |s| -s.id })
    end

    it "filters by server_id when provided" do
      server = create_server
      ss1 = create_server_stat(server:)
      create_server_stat
      ss3 = create_server_stat(server:)

      result = described_class.new(server_id: server.id).call

      assert_equal(2, result.size)
      assert_includes(result, ss1)
      assert_includes(result, ss3)
    end

    it "filters by game_id when provided" do
      game = create_game
      ss1 = create_server_stat(game:)
      create_server_stat
      ss3 = create_server_stat(game:)

      result = described_class.new(game_id: game.id).call

      assert_equal(2, result.size)
      assert_includes(result, ss1)
      assert_includes(result, ss3)
    end
  end
end
