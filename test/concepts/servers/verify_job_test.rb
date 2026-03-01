require "test_helper"

class Servers::VerifyJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::VerifyJob }

  describe "#perform" do
    it "calls Verify for server" do
      server = create_server

      called = 0
      Servers::Verify.stub(:call, ->(arg) {
        called += 1
        assert_equal(arg, server)
        nil
      }) do
        described_class.new.perform(server)
      end
      assert_equal(1, called)
    end
  end
end
