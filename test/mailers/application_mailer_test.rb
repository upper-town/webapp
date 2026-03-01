require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  it "defaults from to NOREPLY_EMAIL" do
    assert_equal(ENV.fetch("NOREPLY_EMAIL"), ApplicationMailer.default[:from])
  end
end
