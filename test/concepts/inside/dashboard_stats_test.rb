require "test_helper"

class Inside::DashboardStatsTest < ActiveSupport::TestCase
  let(:described_class) { Inside::DashboardStats }

  describe "#call" do
    it "returns counts for account servers and votes" do
      account = create_account
      create_server_account(account:)
      create_server_account(account:)
      create_server_account(account:, server: create_server(archived_at: Time.current))
      create_server_vote(account:)
      create_server_vote(account:)

      stats = described_class.call(account)

      assert_equal 3, stats[:servers_count]
      assert_equal 2, stats[:server_votes_count]
      assert_equal 1, stats[:servers_archived_count]
    end

    it "returns zero counts for account with no servers" do
      account = create_account

      stats = described_class.call(account)

      assert_equal 0, stats[:servers_count]
      assert_equal 0, stats[:servers_verified_count]
      assert_equal 0, stats[:servers_pending_count]
      assert_equal 0, stats[:servers_archived_count]
      assert_equal 0, stats[:server_votes_count]
    end
  end
end
