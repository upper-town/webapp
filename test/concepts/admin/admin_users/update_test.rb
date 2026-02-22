# frozen_string_literal: true

require "test_helper"

class Admin::AdminUsers::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AdminUsers::Update }

  describe "#call" do
    it "locks admin user when locked is true" do
      admin_user = create_admin_user(locked_at: nil, locked_reason: nil, locked_comment: nil)
      form = Admin::AdminUsers::EditForm.new(
        admin_user:,
        locked: true,
        locked_reason: "Abuse",
        locked_comment: "Repeated violations"
      )

      result = described_class.call(admin_user, form)

      assert(result.success?)
      assert_equal(admin_user, result.admin_user)
      admin_user.reload
      assert(admin_user.locked?)
      assert_equal("Abuse", admin_user.locked_reason)
      assert_equal("Repeated violations", admin_user.locked_comment)
    end

    it "unlocks admin user when locked is false" do
      admin_user = create_admin_user(locked_at: Time.current, locked_reason: "Abuse", locked_comment: "Note")
      form = Admin::AdminUsers::EditForm.new(admin_user:, locked: false)

      result = described_class.call(admin_user, form)

      assert(result.success?)
      assert_equal(admin_user, result.admin_user)
      admin_user.reload
      assert_not(admin_user.locked?)
      assert_nil(admin_user.locked_reason)
      assert_nil(admin_user.locked_comment)
    end

    it "returns failure when locked is true but locked_reason is blank" do
      admin_user = create_admin_user(locked_at: nil)
      form = Admin::AdminUsers::EditForm.new(admin_user:, locked: true, locked_reason: "", locked_comment: nil)

      result = described_class.call(admin_user, form)

      assert(result.failure?)
      assert_nil(result.admin_user)
      assert(result.errors.key?(:locked_reason))
      assert_not(admin_user.reload.locked?)
    end

    it "returns success when locked is false and locked_reason is blank" do
      admin_user = create_admin_user(locked_at: nil)
      form = Admin::AdminUsers::EditForm.new(admin_user:, locked: false, locked_reason: "", locked_comment: nil)

      result = described_class.call(admin_user, form)

      assert(result.success?)
      assert_equal(admin_user, result.admin_user)
      assert_not(admin_user.reload.locked?)
    end
  end
end
