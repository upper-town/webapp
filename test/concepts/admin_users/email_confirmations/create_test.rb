require "test_helper"

class AdminUsers::EmailConfirmations::CreateTest < ActiveSupport::TestCase
  let(:described_class) { AdminUsers::EmailConfirmations::Create }

  describe "#call" do
    it "delegates to AdminUsers::Create and returns its result" do
      email = "admin_user@upper.town"

      result = described_class.call(email)

      assert(result.success?)
      assert_equal(AdminUser.last, result.admin_user)
      assert_equal(email, result.admin_user.email)
    end

    it "returns failure when AdminUsers::Create returns failure" do
      email = "invalid-email"

      result = described_class.call(email)

      assert(result.failure?)
      assert_nil(result.admin_user)
      assert(result.errors.key?(:email))
    end
  end
end
