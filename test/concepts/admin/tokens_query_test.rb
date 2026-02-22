# frozen_string_literal: true

require "test_helper"

class Admin::TokensQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::TokensQuery }

  describe "#call" do
    it "returns all tokens ordered by id desc" do
      token1 = create_token
      token2 = create_token
      token3 = create_token

      assert_equal(
        [
          token3,
          token2,
          token1
        ],
        described_class.new.call
      )
    end
  end
end
