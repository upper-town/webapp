require "test_helper"

class TimeZoneSelectOptionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { TimeZoneSelectOptionsQuery }

  describe "#call" do
    it "returns standard timezone options including common zones" do
      result = described_class.call(selected_time_zone: nil)

      assert result.any? { |label, value| value == "America/New_York" }
      assert result.none? { |label, _value| label.include?("Browser") }
    end

    it "includes browser timezone when it is not in the standard list" do
      result = described_class.call(selected_time_zone: "Pacific/Kiritimati")

      assert result.any? { |_label, value| value == "Pacific/Kiritimati" }
    end

    it "does not duplicate when selected timezone is already in the list" do
      result = described_class.call(selected_time_zone: "America/New_York")

      america_count = result.count { |_label, value| value == "America/New_York" }
      assert_equal 1, america_count
    end
  end
end
