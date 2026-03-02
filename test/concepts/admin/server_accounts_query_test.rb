require "test_helper"

class Admin::ServerAccountsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::ServerAccountsQuery }

  describe "#call" do
    it "returns all server accounts ordered by id desc" do
      sa1 = create_server_account
      sa2 = create_server_account
      sa3 = create_server_account

      assert_equal(
        [sa3, sa2, sa1],
        described_class.call.to_a
      )
    end

    it "filters by server_id when provided" do
      server = create_server
      sa1 = create_server_account(server:)
      create_server_account
      sa3 = create_server_account(server:)

      result = described_class.call(server_id: server.id).to_a

      assert_equal([sa3, sa1], result)
    end

    it "filters by account_id when provided" do
      account = create_account
      sa1 = create_server_account(account:)
      create_server_account
      sa3 = create_server_account(account:)

      result = described_class.call(account_id: account.id).to_a

      assert_equal([sa3, sa1], result)
    end
  end
end
