require "test_helper"

class Admin::FeatureFlagsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::FeatureFlagsQuery }

  describe "#call" do
    it "returns all feature flags ordered by id desc" do
      flag1 = create_feature_flag
      flag2 = create_feature_flag
      flag3 = create_feature_flag

      assert_equal(
        [
          flag3,
          flag2,
          flag1
        ],
        described_class.new.call
      )
    end
  end
end
