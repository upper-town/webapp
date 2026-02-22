# frozen_string_literal: true

require "test_helper"

class Admin::CodesQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::CodesQuery }

  describe "#call" do
    it "returns all codes ordered by id desc" do
      code1 = create_code
      code2 = create_code
      code3 = create_code

      assert_equal(
        [
          code3,
          code2,
          code1
        ],
        described_class.new.call
      )
    end
  end
end
