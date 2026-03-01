require "test_helper"

class Admin::Users::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Admin::Users::Update }

  describe "#call" do
    it "locks user when locked is true" do
      user = create_user(locked_at: nil, locked_reason: nil, locked_comment: nil)
      form = Admin::Users::EditForm.new(user:, locked: true, locked_reason: "Abuse", locked_comment: "Repeated violations")

      result = described_class.call(user, form)

      assert(result.success?)
      assert_equal(user, result.user)
      user.reload
      assert(user.locked?)
      assert_equal("Abuse", user.locked_reason)
      assert_equal("Repeated violations", user.locked_comment)
    end

    it "unlocks user when locked is false" do
      user = create_user(locked_at: Time.current, locked_reason: "Abuse", locked_comment: "Note")
      form = Admin::Users::EditForm.new(user:, locked: false)

      result = described_class.call(user, form)

      assert(result.success?)
      assert_equal(user, result.user)
      user.reload
      assert_not(user.locked?)
      assert_nil(user.locked_reason)
      assert_nil(user.locked_comment)
    end

    it "returns failure when locked is true but locked_reason is blank" do
      user = create_user(locked_at: nil)
      form = Admin::Users::EditForm.new(user:, locked: true, locked_reason: "", locked_comment: nil)

      result = described_class.call(user, form)

      assert(result.failure?)
      assert_nil(result.user)
      assert(result.errors.key?(:locked_reason))
      assert_not(user.reload.locked?)
    end

    it "returns success when locked is false and locked_reason is blank" do
      user = create_user(locked_at: nil)
      form = Admin::Users::EditForm.new(user:, locked: false, locked_reason: "", locked_comment: nil)

      result = described_class.call(user, form)

      assert(result.success?)
      assert_equal(user, result.user)
      assert_not(user.reload.locked?)
    end
  end
end
