# frozen_string_literal: true

require "test_helper"

class Admin::AdminAccountsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AdminAccountsQuery }

  describe "#call" do
    it "returns all admin accounts ordered by id desc" do
      account1 = create_admin_account
      account2 = create_admin_account
      account3 = create_admin_account

      assert_equal(
        [
          account3,
          account2,
          account1
        ],
        described_class.new.call
      )
    end
  end
end
