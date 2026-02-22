# frozen_string_literal: true

require "test_helper"

module Admin
  module FeatureFlags
    class UpdateTest < ActiveSupport::TestCase
      let(:described_class) { Update }

      describe "#call" do
        it "updates a feature flag with valid attributes" do
          feature_flag = create_feature_flag(name: "old_name", value: "true")
          form = Admin::FeatureFlags::Form.new(feature_flag:, name: "new_name", value: "false")

          result = described_class.call(feature_flag, form)

          assert result.success?
          assert_equal "new_name", result.feature_flag.name
          assert_equal "false", result.feature_flag.value
        end

        it "returns failure when value is blank" do
          feature_flag = create_feature_flag
          form = Admin::FeatureFlags::Form.new(feature_flag:, value: "")

          result = described_class.call(feature_flag, form)

          assert result.failure?
          assert result.errors[:value].present?
        end
      end
    end
  end
end
