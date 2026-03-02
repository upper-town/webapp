require "test_helper"

class Filter::ByDateRangeTest < ActiveSupport::TestCase
  let(:described_class) { Admin::ServerVotesFilterQuery }

  describe "by_date_range mixin" do
    it "returns all records when dates are blank" do
      create_server_vote
      create_server_vote

      relation = ServerVote.all
      result = described_class.call(relation, start_date: nil, end_date: nil)

      assert_equal(2, result.count)
    end

    it "filters by start_date when provided" do
      sv_before = create_server_vote
      sv_before.update_columns(created_at: Time.zone.parse("2024-01-14 23:59:59"))
      sv_in = create_server_vote
      sv_in.update_columns(created_at: Time.zone.parse("2024-01-15 12:00:00"))
      sv_after = create_server_vote
      sv_after.update_columns(created_at: Time.zone.parse("2024-01-16 00:00:00"))

      relation = ServerVote.all
      result = described_class.call(relation, start_date: "2024-01-15")

      assert_includes(result, sv_in)
      assert_includes(result, sv_after)
      assert_not_includes(result, sv_before)
      assert_equal(2, result.count)
    end

    it "filters by end_date when provided" do
      sv_before = create_server_vote
      sv_before.update_columns(created_at: Time.zone.parse("2024-01-19 23:59:59"))
      sv_in = create_server_vote
      sv_in.update_columns(created_at: Time.zone.parse("2024-01-20 12:00:00"))
      sv_after = create_server_vote
      sv_after.update_columns(created_at: Time.zone.parse("2024-01-21 00:00:00"))

      relation = ServerVote.all
      result = described_class.call(relation, end_date: "2024-01-20")

      assert_includes(result, sv_before)
      assert_includes(result, sv_in)
      assert_not_includes(result, sv_after)
      assert_equal(2, result.count)
    end

    it "swaps start_date and end_date when start_date is after end_date" do
      sv_before = create_server_vote
      sv_before.update_columns(created_at: Time.zone.parse("2024-01-14 23:59:59"))
      sv_in1 = create_server_vote
      sv_in1.update_columns(created_at: Time.zone.parse("2024-01-15 00:00:00"))
      sv_in2 = create_server_vote
      sv_in2.update_columns(created_at: Time.zone.parse("2024-01-20 23:59:59"))
      sv_after = create_server_vote
      sv_after.update_columns(created_at: Time.zone.parse("2024-01-21 00:00:00"))

      relation = ServerVote.all
      result = described_class.call(relation, start_date: "2024-01-20", end_date: "2024-01-15")

      assert_includes(result, sv_in1)
      assert_includes(result, sv_in2)
      assert_not_includes(result, sv_before)
      assert_not_includes(result, sv_after)
      assert_equal(2, result.count)
    end
  end
end
