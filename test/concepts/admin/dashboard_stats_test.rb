require "test_helper"

class Admin::DashboardStatsTest < ActiveSupport::TestCase
  let(:described_class) { Admin::DashboardStats }

  describe "#call" do
    it "returns counts for users, admin users, and servers" do
      create_user
      create_user
      create_admin_user
      create_server
      create_server
      create_server

      stats = described_class.call

      assert_equal 2, stats[:users_count]
      assert_equal 1, stats[:admin_users_count]
      assert_equal 3, stats[:servers_count]
    end

    it "returns locked counts when users or admin users are locked" do
      user = create_user
      admin_user = create_admin_user

      stats = described_class.call
      assert_equal 0, stats[:users_locked_count]
      assert_equal 0, stats[:admin_users_locked_count]

      user.lock_access!("Test", "Test")
      admin_user.lock_access!("Test", "Test")

      stats = described_class.call
      assert_equal 1, stats[:users_locked_count]
      assert_equal 1, stats[:admin_users_locked_count]
    end

    it "returns server status counts" do
      create_server(verified_at: Time.current)
      create_server(archived_at: Time.current)
      create_server(marked_for_deletion_at: Time.current)

      stats = described_class.call

      assert_equal 3, stats[:servers_count]
      assert_equal 1, stats[:servers_verified_count]
      assert_equal 1, stats[:servers_archived_count]
      assert_equal 1, stats[:servers_marked_for_deletion_count]
    end
  end
end
