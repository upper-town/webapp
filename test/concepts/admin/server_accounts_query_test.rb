# frozen_string_literal: true

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
        described_class.new.call
      )
    end

    it "filters by server_id when provided" do
      server = create_server
      sa1 = create_server_account(server: server)
      sa2 = create_server_account
      sa3 = create_server_account(server: server)

      result = described_class.new(server_id: server.id).call

      assert_equal([sa3, sa1], result)
    end

    it "filters by account_id when provided" do
      account = create_account
      sa1 = create_server_account(account: account)
      sa2 = create_server_account
      sa3 = create_server_account(account: account)

      result = described_class.new(account_id: account.id).call

      assert_equal([sa3, sa1], result)
    end
  end
end
