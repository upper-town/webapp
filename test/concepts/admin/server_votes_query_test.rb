require "test_helper"

class Admin::ServerVotesQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::ServerVotesQuery }

  describe "#call" do
    it "returns all server votes ordered by id desc" do
      sv1 = create_server_vote
      sv2 = create_server_vote
      sv3 = create_server_vote

      assert_equal(
        [sv3, sv2, sv1],
        described_class.new.call
      )
    end

    it "filters by server_id when provided" do
      server = create_server
      sv1 = create_server_vote(server:)
      create_server_vote
      sv3 = create_server_vote(server:)

      result = described_class.new(server_id: server.id).call

      assert_equal([sv3, sv1], result)
    end

    it "filters by game_id when provided" do
      game = create_game
      sv1 = create_server_vote(game:)
      create_server_vote
      sv3 = create_server_vote(game:)

      result = described_class.new(game_id: game.id).call

      assert_equal([sv3, sv1], result)
    end

    it "filters by account_id when provided" do
      account = create_account
      sv1 = create_server_vote(account:)
      create_server_vote
      sv3 = create_server_vote(account:)

      result = described_class.new(account_id: account.id).call

      assert_equal([sv3, sv1], result)
    end
  end
end
