# frozen_string_literal: true

require "test_helper"

class Servers::CreateVoteTest < ActiveSupport::TestCase
  let(:described_class) { Servers::CreateVote }

  describe "#call" do
    describe "when server_vote is invalid for some reason" do
      it "returns failure and does not create server_vote nor webhook events" do
        server = create_server(archived_at: Time.current)
        account = create_account
        form = Servers::VoteForm.new(reference: "ref")

        webhooks_create_events_called = 0
        Webhooks::CreateEvents.stub(:call, ->(*) { webhooks_create_events_called += 1 ; nil }) do
          result = nil
          assert_no_difference(-> { ServerVote.count }) do
            result = described_class.call(
              form,
              server_id: server.id,
              remote_ip: "1.1.1.1",
              account_id: account.id
            )
          end

          assert(result.failure?)
          assert(result.errors[:server].any? { it.include?("cannot be archived") })
          assert_not_nil(result.server_vote)
        end
        assert_equal(0, webhooks_create_events_called)
      end
    end

    describe "when server_id is invalid" do
      it "returns failure with server not_found and does not create server_vote" do
        form = Servers::VoteForm.new(reference: "ref")

        assert_no_difference(-> { ServerVote.count }) do
          result = described_class.call(
            form,
            server_id: 999_999_999,
            remote_ip: "1.1.1.1",
            account_id: nil
          )

          assert(result.failure?)
          assert(result.errors[:server].present?)
          assert_nil(result.server_vote)
        end
      end
    end

    describe "when an error is raised" do
      it "raises error" do
        server = create_server
        account = create_account
        form = Servers::VoteForm.new(reference: "ref")

        ServerVote.stub_any_instance(:save!, -> { raise ActiveRecord::ActiveRecordError }) do
          assert_no_difference(-> { ServerVote.count }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.call(
                form,
                server_id: server.id,
                remote_ip: "1.1.1.1",
                account_id: account.id
              )
            end
          end
        end
      end
    end

    describe "when everything is correct" do
      it "returns success, creates server_vote and webhook events" do
        server = create_server
        account = create_account
        form = Servers::VoteForm.new(reference: "anything123456")

        webhooks_create_events_called = 0
        Webhooks::CreateEvents.stub(:call, ->(*webhooks_create_events_args) do
          webhooks_create_events_called += 1
          assert_equal(server, webhooks_create_events_args[0])
          assert_equal("server_vote.created", webhooks_create_events_args[1])
          assert_equal(ServerVote.last, webhooks_create_events_args[2])
          nil
        end) do
          result = nil
          assert_difference(-> { ServerVote.count }, 1) do
            result = described_class.call(
              form,
              server_id: server.id,
              remote_ip: "1.1.1.1",
              account_id: account.id
            )
          end

          assert(result.success?)
          assert_equal(ServerVote.last, result.server_vote)
          assert_equal(server, result.server_vote.server)
          assert_equal(server.game, result.server_vote.game)
          assert_equal("1.1.1.1", result.server_vote.remote_ip)
          assert_equal("anything123456", result.server_vote.reference)
          assert_equal(account, result.server_vote.account)
        end
        assert_equal(1, webhooks_create_events_called)
      end
    end
  end
end
