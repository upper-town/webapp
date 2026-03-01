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

    it "filters by game_ids when provided" do
      game1 = create_game
      game2 = create_game
      game3 = create_game
      sv1 = create_server_vote(game: game1)
      sv2 = create_server_vote(game: game2)
      create_server_vote(game: game3)

      result = described_class.new(game_ids: [game1.id, game2.id]).call

      assert_includes(result, sv1)
      assert_includes(result, sv2)
      assert_equal(2, result.count)
    end

    it "filters by server_ids when provided" do
      server1 = create_server
      server2 = create_server
      server3 = create_server
      sv1 = create_server_vote(server: server1)
      sv2 = create_server_vote(server: server2)
      create_server_vote(server: server3)

      result = described_class.new(server_ids: [server1.id, server2.id]).call

      assert_includes(result, sv1)
      assert_includes(result, sv2)
      assert_equal(2, result.count)
    end

    it "filters by account_ids when provided" do
      account1 = create_account
      account2 = create_account
      account3 = create_account
      sv1 = create_server_vote(account: account1)
      sv2 = create_server_vote(account: account2)
      create_server_vote(account: account3)

      result = described_class.new(account_ids: [account1.id, account2.id]).call

      assert_includes(result, sv1)
      assert_includes(result, sv2)
      assert_equal(2, result.count)
    end

    it "prefers game_ids over game_id when both provided" do
      game1 = create_game
      game2 = create_game
      sv1 = create_server_vote(game: game1)
      create_server_vote(game: game2)

      result = described_class.new(game_id: game2.id, game_ids: [game1.id]).call

      assert_equal([sv1], result)
    end

    it "filters by anonymous when account_ids includes anonymous sentinel" do
      account = create_account
      create_server_vote(account:)
      sv_anonymous = create_server_vote(account: nil)

      result = described_class.new(account_ids: [described_class::ANONYMOUS_VALUE]).call

      assert_equal([sv_anonymous], result)
    end

    it "filters by anonymous and specific accounts when both selected" do
      account = create_account
      sv1 = create_server_vote(account:)
      sv_anonymous = create_server_vote(account: nil)

      result = described_class.new(account_ids: [described_class::ANONYMOUS_VALUE, account.id.to_s]).call

      assert_includes(result, sv1)
      assert_includes(result, sv_anonymous)
      assert_equal(2, result.count)
    end
  end
end
