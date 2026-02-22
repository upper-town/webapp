# frozen_string_literal: true

require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "default from uses NOREPLY_EMAIL" do
    assert_equal(ENV.fetch("NOREPLY_EMAIL"), ApplicationMailer.default[:from])
  end
end
