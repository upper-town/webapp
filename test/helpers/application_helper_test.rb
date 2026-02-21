# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  describe "#default_title" do
    it "returns the default title" do
      assert_equal("upper.town", default_title)
    end
  end

  describe "#no_script" do
    it "returns the no-script message" do
      assert_equal(
        "JavaScript is currently disabled on your browser. This website doesn't work without JavaScript.",
        no_script
      )
    end
  end
end
