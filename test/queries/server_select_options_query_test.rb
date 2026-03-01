require "test_helper"

class ServerSelectOptionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { ServerSelectOptionsQuery }

  describe "#call" do
    it "returns options with server name and game name for servers with votes" do
      game = create_game(name: "Minecraft")
      server = create_server(name: "Cool Server", game:)
      create_server_vote(server:, game:)

      result = described_class.new(only_with_votes: true, cache_enabled: false).call

      assert_equal(1, result.size)
      assert_equal("Cool Server", result.first[0])
      assert_equal(server.id, result.first[1])
    end

    it "returns only servers that have votes when only_with_votes is true" do
      game = create_game
      server_with_vote = create_server(game:, name: "With Vote")
      create_server(game:, name: "No Vote")
      create_server_vote(server: server_with_vote, game:)

      result = described_class.new(only_with_votes: true, cache_enabled: false).call

      assert_equal(1, result.size)
      assert_equal(server_with_vote.id, result.first[1])
    end

    it "returns all servers when only_with_votes is false" do
      game = create_game
      server1 = create_server(game:, name: "Alpha")
      server2 = create_server(game:, name: "Beta")

      result = described_class.new(only_with_votes: false, cache_enabled: false).call

      assert_equal(2, result.size)
      ids = result.map(&:last)
      assert_includes(ids, server1.id)
      assert_includes(ids, server2.id)
    end
  end
end
