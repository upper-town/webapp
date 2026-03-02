require "test_helper"

class Admin::UsersFilterQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::UsersFilterQuery }

  describe "#call" do
    it "filters by created_at date range when start_date and end_date provided" do
      user_before = create_user
      user_before.update_columns(created_at: Time.zone.parse("2024-01-14 23:59:59"))
      user_in = create_user
      user_in.update_columns(created_at: Time.zone.parse("2024-01-15 12:00:00"))
      user_after = create_user
      user_after.update_columns(created_at: Time.zone.parse("2024-01-21 00:00:00"))

      result = described_class.call(
        User.all,
        start_date: "2024-01-15",
        end_date: "2024-01-20"
      )

      assert_includes(result, user_in)
      assert_not_includes(result, user_before)
      assert_not_includes(result, user_after)
      assert_equal(1, result.count)
    end

    it "filters by created_at with start_time and end_time when provided" do
      user_before = create_user
      user_before.update_columns(created_at: Time.zone.parse("2024-01-15 08:59:59"))
      user_in = create_user
      user_in.update_columns(created_at: Time.zone.parse("2024-01-15 12:00:00"))
      user_after = create_user
      user_after.update_columns(created_at: Time.zone.parse("2024-01-15 18:00:01"))

      result = described_class.call(
        User.all,
        start_date: "2024-01-15",
        end_date: "2024-01-15",
        start_time: "09:00:00",
        end_time: "18:00:00"
      )

      assert_includes(result, user_in)
      assert_not_includes(result, user_before)
      assert_not_includes(result, user_after)
      assert_equal(1, result.count)
    end

    it "filters by email_confirmed_at when date_column is email_confirmed_at" do
      user_without = create_user
      user_without.update_columns(email_confirmed_at: nil)
      user_in = create_user
      user_in.update_columns(email_confirmed_at: Time.zone.parse("2024-01-15 12:00:00"))
      user_after = create_user
      user_after.update_columns(email_confirmed_at: Time.zone.parse("2024-01-21 00:00:00"))

      result = described_class.call(
        User.all,
        start_date: "2024-01-15",
        end_date: "2024-01-20",
        date_column: "email_confirmed_at"
      )

      assert_includes(result, user_in)
      assert_not_includes(result, user_without)
      assert_not_includes(result, user_after)
      assert_equal(1, result.count)
    end

    it "filters by locked_at when date_column is locked_at" do
      user_without = create_user
      user_without.update_columns(locked_at: nil)
      user_in = create_user
      user_in.update_columns(locked_at: Time.zone.parse("2024-01-15 12:00:00"))

      result = described_class.call(
        User.all,
        start_date: "2024-01-15",
        end_date: "2024-01-20",
        date_column: "locked_at"
      )

      assert_includes(result, user_in)
      assert_not_includes(result, user_without)
      assert_equal(1, result.count)
    end

    it "defaults to created_at when date_column is invalid" do
      user = create_user
      user.update_columns(created_at: Time.zone.parse("2024-01-15 12:00:00"))

      result = described_class.call(
        User.all,
        start_date: "2024-01-15",
        end_date: "2024-01-15",
        date_column: "invalid_column"
      )

      assert_includes(result, user)
      assert_equal(1, result.count)
    end

    it "returns relation unchanged when no filter params provided" do
      create_user
      create_user

      result = described_class.call(User.all, {})

      assert_equal(2, result.count)
    end
  end
end
