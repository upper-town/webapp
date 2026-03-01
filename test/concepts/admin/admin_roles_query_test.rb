require "test_helper"

class Admin::AdminRolesQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::AdminRolesQuery }

  describe "#call" do
    it "returns all admin roles ordered by key" do
      role_z = create_admin_role(key: "zebra")
      role_a = create_admin_role(key: "alpha")
      role_m = create_admin_role(key: "middle")

      assert_equal(
        [role_a, role_m, role_z],
        described_class.new.call
      )
    end
  end
end
