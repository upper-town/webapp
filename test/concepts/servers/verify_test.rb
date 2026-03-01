require "test_helper"

class Servers::VerifyTest < ActiveSupport::TestCase
  let(:described_class) { Servers::Verify }

  describe "#call" do
    describe "when VerifyAccounts::Perform suceeds" do
      it "updates server as verified" do
        freeze_time do
          server = create_server(verified_at: nil, metadata: { notice: "something" })

          called = 0
          Servers::VerifyAccounts::Perform.stub(:call, ->(srv, _current_time = nil) {
            called += 1
            assert_equal(srv, server)
            Result.success
          }) do
            described_class.call(server)
          end
          assert_equal(1, called)

          server.reload
          assert_equal(Time.current, server.verified_at)
          assert_equal({}, server.metadata)
        end
      end
    end

    describe "when VerifyAccounts::Perform fails" do
      it "updates server as not verified" do
        server = create_server(verified_at: Time.current, metadata: {})

        failure_result = Result.new
        failure_result.add_error("an error")
        failure_result.add_error("another error")

        called = 0
        Servers::VerifyAccounts::Perform.stub(:call, ->(srv, _current_time = nil) {
          called += 1
          assert_equal(srv, server)
          failure_result
        }) do
          described_class.call(server)
        end
        assert_equal(1, called)

        server.reload
        assert_nil(server.verified_at)
        assert_equal("an error; another error", server.metadata["notice"])
      end
    end
  end
end
