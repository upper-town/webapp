# frozen_string_literal: true

require "test_helper"

module Admin
  module FeatureFlags
    class CreateTest < ActiveSupport::TestCase
      let(:described_class) { Create }

      describe "#call" do
        it "creates a feature flag with valid attributes" do
          form = Admin::FeatureFlags::Form.new(name: "my_feature", value: "true", comment: "Test feature")
          result = described_class.call(form)

          assert result.success?
          assert_equal "my_feature", result.feature_flag.name
          assert_equal "true", result.feature_flag.value
          assert_equal "Test feature", result.feature_flag.comment
        end

        it "returns failure when name is blank" do
          form = Admin::FeatureFlags::Form.new(name: "", value: "true")
          result = described_class.call(form)

          assert result.failure?
          assert result.errors[:name].present?
        end

        it "returns failure when value is blank" do
          form = Admin::FeatureFlags::Form.new(name: "my_feature", value: "")
          result = described_class.call(form)

          assert result.failure?
          assert result.errors[:value].present?
        end

        it "returns failure when name is duplicate" do
          create_feature_flag(name: "existing_flag", value: "true")

          form = Admin::FeatureFlags::Form.new(name: "existing_flag", value: "false")
          result = described_class.call(form)

          assert result.failure?
          assert result.errors[:name].present?
        end
      end
    end
  end
end
