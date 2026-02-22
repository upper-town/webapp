# frozen_string_literal: true

require "test_helper"

class Admin::SessionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::SessionsQuery }

  describe "#call" do
    it "returns all sessions ordered by id desc" do
      session1 = create_session
      session2 = create_session
      session3 = create_session

      assert_equal(
        [
          session3,
          session2,
          session1
        ],
        described_class.new.call
      )
    end
  end
end
