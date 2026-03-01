require "test_helper"

class Demo::ConstraintTest < ActiveSupport::TestCase
  let(:described_class) { Demo::Constraint }

  describe "#matches?" do
    describe "when Rails.env is development" do
      it "returns true" do
        rails_with_env("development") do
          request = build_request

          assert(described_class.new.matches?(request))
        end
      end
    end

    describe "when Rails.env is not development" do
      it "returns false" do
        rails_with_env("test") do
          request = build_request

          assert_not(described_class.new.matches?(request))
        end

        rails_with_env("production") do
          request = build_request

          assert_not(described_class.new.matches?(request))
        end
      end
    end
  end
end
