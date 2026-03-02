require "test_helper"

class Admin::UsersQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::UsersQuery }

  describe "#call" do
    it "returns all users ordered by id desc" do
      user1 = create_user
      user2 = create_user
      user3 = create_user

      assert_equal(
        [
          user3,
          user2,
          user1
        ],
        described_class.new.call
      )
    end

    it "filters by date range when start_date and end_date provided" do
      user_before = create_user
      user_before.update_columns(created_at: Time.zone.parse("2024-01-14 23:59:59"))
      user_in = create_user
      user_in.update_columns(created_at: Time.zone.parse("2024-01-15 12:00:00"))
      user_after = create_user
      user_after.update_columns(created_at: Time.zone.parse("2024-01-21 00:00:00"))

      result = described_class.new(
        start_date: "2024-01-15",
        end_date: "2024-01-20"
      ).call

      assert_includes(result, user_in)
      assert_not_includes(result, user_before)
      assert_not_includes(result, user_after)
      assert_equal(1, result.count)
    end

    it "filters by date range with time when start_time and end_time provided" do
      user_before = create_user
      user_before.update_columns(created_at: Time.zone.parse("2024-01-15 08:59:59"))
      user_in = create_user
      user_in.update_columns(created_at: Time.zone.parse("2024-01-15 12:00:00"))
      user_after = create_user
      user_after.update_columns(created_at: Time.zone.parse("2024-01-15 18:00:01"))

      result = described_class.new(
        start_date: "2024-01-15",
        end_date: "2024-01-15",
        start_time: "09:00:00",
        end_time: "18:00:00"
      ).call

      assert_includes(result, user_in)
      assert_not_includes(result, user_before)
      assert_not_includes(result, user_after)
      assert_equal(1, result.count)
    end
  end
end
