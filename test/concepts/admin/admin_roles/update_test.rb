require "test_helper"

module Admin
  module AdminRoles
    class UpdateTest < ActiveSupport::TestCase
      let(:described_class) { Update }

      describe "#call" do
        it "updates role permissions" do
          role = create_admin_role
          perm1 = create_admin_permission
          perm2 = create_admin_permission
          perm3 = create_admin_permission

          create_admin_role_permission(admin_role: role, admin_permission: perm1)
          create_admin_role_permission(admin_role: role, admin_permission: perm2)

          form = Admin::AdminRoles::UpdateForm.new(permission_ids: [perm2.id, perm3.id])
          result = described_class.call(role, form)

          assert result.success?
          assert_equal [perm2.id, perm3.id].sort, role.reload.permission_ids.sort
        end

        it "handles empty permission_ids" do
          role = create_admin_role
          perm = create_admin_permission
          create_admin_role_permission(admin_role: role, admin_permission: perm)

          form = Admin::AdminRoles::UpdateForm.new(permission_ids: [])
          result = described_class.call(role, form)

          assert result.success?
          assert_empty role.reload.permission_ids
        end

        it "handles nil permission_ids" do
          role = create_admin_role
          perm = create_admin_permission
          create_admin_role_permission(admin_role: role, admin_permission: perm)

          form = Admin::AdminRoles::UpdateForm.new(permission_ids: nil)
          result = described_class.call(role, form)

          assert result.success?
          assert_empty role.reload.permission_ids
        end

        it "rejects invalid permission_ids" do
          role = create_admin_role
          perm = create_admin_permission
          create_admin_role_permission(admin_role: role, admin_permission: perm)

          form = Admin::AdminRoles::UpdateForm.new(permission_ids: [perm.id, 999_999])
          assert form.invalid?
          assert form.errors.key?(:permission_ids)
        end
      end
    end
  end
end
