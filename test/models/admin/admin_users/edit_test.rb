require "test_helper"

class Admin::AdminUsers::EditFormTest < ActiveSupport::TestCase
  describe "validation" do
    it "is invalid when locked is true but locked_reason is blank" do
      admin_user = create_admin_user(locked_at: nil)
      edit = Admin::AdminUsers::EditForm.new(admin_user:, locked: true, locked_reason: "", locked_comment: nil)

      assert_not(edit.valid?)
      assert_includes(edit.errors[:locked_reason], "can't be blank")
    end

    it "is valid when locked is false and locked_reason is blank" do
      admin_user = create_admin_user(locked_at: nil)
      edit = Admin::AdminUsers::EditForm.new(admin_user:, locked: false, locked_reason: "", locked_comment: nil)

      assert(edit.valid?)
    end

    it "initializes from admin_user lock state" do
      admin_user = create_admin_user(locked_at: Time.current, locked_reason: "Abuse", locked_comment: "Note")
      edit = Admin::AdminUsers::EditForm.new(admin_user:)

      assert(edit.locked?)
      assert_equal("Abuse", edit.locked_reason)
      assert_equal("Note", edit.locked_comment)
    end
  end
end
