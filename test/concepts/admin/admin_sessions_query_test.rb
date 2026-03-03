require "test_helper"

class Admin::AdminSessionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AdminSessionsQuery }

  describe "#call" do
    it "returns all admin sessions ordered by id desc" do
      admin_session1 = create_admin_session
      admin_session2 = create_admin_session
      admin_session3 = create_admin_session

      assert_equal(
        [
          admin_session3,
          admin_session2,
          admin_session1
        ],
        described_class.call.to_a
      )
    end

    it "filters by admin_user_id when provided" do
      admin_user = create_admin_user
      session_for_user = create_admin_session(admin_user:)
      create_admin_session(admin_user: create_admin_user)

      result = described_class.call(admin_user_id: admin_user.id).to_a

      assert_equal([session_for_user], result)
    end
  end
end
