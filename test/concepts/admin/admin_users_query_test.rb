require "test_helper"

class Admin::AdminUsersQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AdminUsersQuery }

  describe "#call" do
    it "returns all admin users ordered by id desc" do
      admin_user1 = create_admin_user
      admin_user2 = create_admin_user
      admin_user3 = create_admin_user

      assert_equal(
        [
          admin_user3,
          admin_user2,
          admin_user1
        ],
        described_class.new.call
      )
    end
  end
end
