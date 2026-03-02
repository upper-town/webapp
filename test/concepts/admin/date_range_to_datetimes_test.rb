require "test_helper"

class Admin::DateRangeToDatetimesTest < ActiveSupport::TestCase
  let(:described_class) { Admin::DateRangeToDatetimes }

  describe "#call" do
    it "returns start_datetime and end_datetime when both dates parse" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "2024-01-20",
        time_zone: "UTC"
      )

      assert_equal(Time.zone.parse("2024-01-15").beginning_of_day, result[:start_datetime])
      assert_equal(Time.zone.parse("2024-01-20").end_of_day, result[:end_datetime])
    end

    it "returns only start_datetime when end_date is nil" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: nil,
        time_zone: "UTC"
      )

      assert_equal(Time.zone.parse("2024-01-15").beginning_of_day, result[:start_datetime])
      assert_nil(result[:end_datetime])
    end

    it "returns only end_datetime when start_date is nil" do
      result = described_class.call(
        start_date: nil,
        end_date: "2024-01-20",
        time_zone: "UTC"
      )

      assert_nil(result[:start_datetime])
      assert_equal(Time.zone.parse("2024-01-20").end_of_day, result[:end_datetime])
    end

    it "falls back to Time.zone when time_zone is nil" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "2024-01-20",
        time_zone: nil
      )

      assert_equal(Time.zone.parse("2024-01-15").beginning_of_day, result[:start_datetime])
      assert_equal(Time.zone.parse("2024-01-20").end_of_day, result[:end_datetime])
    end

    it "falls back to Time.zone when time_zone is invalid" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "2024-01-20",
        time_zone: "Invalid/Timezone"
      )

      assert_equal(Time.zone.parse("2024-01-15").beginning_of_day, result[:start_datetime])
      assert_equal(Time.zone.parse("2024-01-20").end_of_day, result[:end_datetime])
    end

    it "returns nil for unparseable start_date" do
      result = described_class.call(
        start_date: "not-a-date",
        end_date: "2024-01-20",
        time_zone: "UTC"
      )

      assert_nil(result[:start_datetime])
      assert_equal(Time.zone.parse("2024-01-20").end_of_day, result[:end_datetime])
    end

    it "returns nil for unparseable end_date" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "invalid",
        time_zone: "UTC"
      )

      assert_equal(Time.zone.parse("2024-01-15").beginning_of_day, result[:start_datetime])
      assert_nil(result[:end_datetime])
    end

    it "interprets dates in the given timezone" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "2024-01-15",
        time_zone: "America/New_York"
      )

      tz = ActiveSupport::TimeZone["America/New_York"]
      expected_start = tz.parse("2024-01-15").beginning_of_day
      expected_end = tz.parse("2024-01-15").end_of_day

      assert_equal(expected_start, result[:start_datetime])
      assert_equal(expected_end, result[:end_datetime])
    end

    it "combines date and time when start_time and end_time are provided" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "2024-01-15",
        start_time: "09:30:45",
        end_time: "17:00:00",
        time_zone: "UTC"
      )

      expected_start = Time.zone.parse("2024-01-15 09:30:45")
      expected_end = Time.zone.parse("2024-01-15 17:00:00")

      assert_equal(expected_start, result[:start_datetime])
      assert_equal(expected_end, result[:end_datetime])
    end

    it "defaults to beginning_of_day when start_time is blank" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "2024-01-15",
        end_time: "12:00:00",
        time_zone: "UTC"
      )

      assert_equal(Time.zone.parse("2024-01-15").beginning_of_day, result[:start_datetime])
      assert_equal(Time.zone.parse("2024-01-15 12:00:00"), result[:end_datetime])
    end

    it "defaults to end_of_day when end_time is blank" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "2024-01-15",
        start_time: "08:00:00",
        time_zone: "UTC"
      )

      assert_equal(Time.zone.parse("2024-01-15 08:00:00"), result[:start_datetime])
      assert_equal(Time.zone.parse("2024-01-15").end_of_day, result[:end_datetime])
    end

    it "accepts HH:mm format for time" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "2024-01-15",
        start_time: "09:30",
        end_time: "17:00",
        time_zone: "UTC"
      )

      assert_equal(Time.zone.parse("2024-01-15 09:30:00"), result[:start_datetime])
      assert_equal(Time.zone.parse("2024-01-15 17:00:00"), result[:end_datetime])
    end

    it "falls back to beginning_of_day when start_time is invalid" do
      result = described_class.call(
        start_date: "2024-01-15",
        end_date: "2024-01-15",
        start_time: "invalid",
        time_zone: "UTC"
      )

      assert_equal(Time.zone.parse("2024-01-15").beginning_of_day, result[:start_datetime])
    end
  end
end
