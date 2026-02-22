# frozen_string_literal: true

require "test_helper"

class Admin::AdminCodesQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AdminCodesQuery }

  describe "#call" do
    it "returns all admin codes ordered by id desc" do
      admin_code1 = create_admin_code
      admin_code2 = create_admin_code
      admin_code3 = create_admin_code

      assert_equal(
        [
          admin_code3,
          admin_code2,
          admin_code1
        ],
        described_class.new.call
      )
    end
  end
end
