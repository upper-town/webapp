require "test_helper"

class AccountSelectOptionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { AccountSelectOptionsQuery }

  describe "#call" do
    it "returns options with email and account id for accounts with votes" do
      account = create_account
      account.user.update!(email: "voter@upper.town")
      server = create_server
      create_server_vote(server:, game: server.game, account:)

      result = described_class.new(only_with_votes: true, cache_enabled: false).call

      assert_operator(result.size, :>=, 1)
      option = result.find { |_label, id| id == account.id }
      assert option, "Expected account #{account.id} in result"
      assert_equal("voter@upper.town", option[0])
    end

    it "returns only accounts that have votes when only_with_votes is true" do
      account_with_vote = create_account
      server = create_server
      create_server_vote(server:, game: server.game, account: account_with_vote)

      result = described_class.new(only_with_votes: true, cache_enabled: false).call

      assert_includes(result.map(&:last), account_with_vote.id)
    end

    it "returns all accounts when only_with_votes is false" do
      account1 = create_account
      account2 = create_account

      result = described_class.new(only_with_votes: false, cache_enabled: false).call

      assert_operator(result.size, :>=, 2)
      ids = result.map(&:last)
      assert_includes(ids, account1.id)
      assert_includes(ids, account2.id)
    end

    it "filters by search_term when provided" do
      account = create_account
      account.user.update!(email: "alice@upper.town")
      other = create_account
      other.user.update!(email: "bob@upper.town")

      result = described_class.new(search_term: "alice", cache_enabled: false).call

      assert_equal(1, result.size)
      assert_equal("alice@upper.town", result.first[0])
    end

    it "returns accounts by ids when provided" do
      account1 = create_account
      account1.user.update!(email: "first@upper.town")
      account2 = create_account
      account2.user.update!(email: "second@upper.town")

      result = described_class.new(ids: [account1.id, account2.id], cache_enabled: false).call

      assert_equal(2, result.size)
      emails = result.map(&:first).sort
      assert_equal(%w[first@upper.town second@upper.town], emails)
    end

    it "respects limit when search_term or ids provided" do
      3.times { |i| create_account.tap { |a| a.user.update!(email: "user#{i}@upper.town") } }

      result = described_class.new(search_term: "user", limit: 2, cache_enabled: false).call

      assert_equal(2, result.size)
    end
  end

end
