# frozen_string_literal: true

require "test_helper"

class Admin::AdminTokensQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AdminTokensQuery }

  describe "#call" do
    it "returns all admin tokens ordered by id desc" do
      admin_token1 = create_admin_token
      admin_token2 = create_admin_token
      admin_token3 = create_admin_token

      assert_equal(
        [
          admin_token3,
          admin_token2,
          admin_token1
        ],
        described_class.new.call
      )
    end
  end
end
