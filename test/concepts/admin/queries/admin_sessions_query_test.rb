# frozen_string_literal: true

require "test_helper"

class Admin::Queries::AdminSessionsQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::Queries::AdminSessionsQuery }

  describe "#call" do
    it "returns relation unchanged when search is blank" do
      create_admin_session
      relation = AdminSession.includes(:admin_user).order(id: :desc)

      assert_equal relation.to_sql, described_class.call(AdminSession, relation, nil).to_sql
      assert_equal relation.to_sql, described_class.call(AdminSession, relation, "").to_sql
    end

    it "filters by id" do
      session = create_admin_session
      create_admin_session

      result = described_class.call(AdminSession, AdminSession.all, session.id.to_s)

      assert_equal [session], result.to_a
    end

    it "filters by token_last_four" do
      session = create_admin_session(token_last_four: "a1b2")
      create_admin_session(token_last_four: "xyz9")

      result = described_class.call(AdminSession, AdminSession.all, "a1b2")

      assert_equal [session], result.to_a
    end

    it "filters by remote_ip" do
      session = create_admin_session(remote_ip: "192.168.1.100")
      create_admin_session(remote_ip: "10.0.0.1")

      result = described_class.call(AdminSession, AdminSession.all, "192.168")

      assert_equal [session], result.to_a
    end

    it "filters by admin user email" do
      admin_user = create_admin_user(email: "unique.searchable@upper.town")
      session = create_admin_session(admin_user:)
      create_admin_session(admin_user: create_admin_user(email: "other@upper.town"))

      result = described_class.call(
        AdminSession.includes(:admin_user),
        AdminSession.all,
        "unique.searchable@upper.town"
      )

      assert_equal [session], result.to_a
    end

    it "returns empty when no matches" do
      create_admin_session

      assert_empty described_class.call(AdminSession, AdminSession.all, "nonexistent-xyz-123").to_a
    end
  end
end
