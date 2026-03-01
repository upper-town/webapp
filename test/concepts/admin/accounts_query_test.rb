require "test_helper"

class Admin::AccountsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AccountsQuery }

  describe "#call" do
    it "returns all accounts ordered by id desc" do
      account1 = create_account
      account2 = create_account
      account3 = create_account

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
