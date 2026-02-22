# frozen_string_literal: true

require "test_helper"

module Admin
  module AdminAccounts
    class UpdateRolesTest < ActiveSupport::TestCase
      let(:described_class) { UpdateRoles }

      describe "#call" do
        it "updates account roles" do
          account = create_admin_account
          role1 = create_admin_role
          role2 = create_admin_role
          role3 = create_admin_role

          create_admin_account_role(admin_account: account, admin_role: role1)
          create_admin_account_role(admin_account: account, admin_role: role2)

          form = Admin::AdminAccounts::UpdateRolesForm.new(role_ids: [role2.id, role3.id])
          result = described_class.call(account, form)

          assert result.success?
          assert_equal [role2.id, role3.id].sort, account.reload.role_ids.sort
        end

        it "handles empty role_ids" do
          account = create_admin_account
          role = create_admin_role
          create_admin_account_role(admin_account: account, admin_role: role)

          form = Admin::AdminAccounts::UpdateRolesForm.new(role_ids: [])
          result = described_class.call(account, form)

          assert result.success?
          assert_empty account.reload.role_ids
        end

        it "handles nil role_ids" do
          account = create_admin_account
          role = create_admin_role
          create_admin_account_role(admin_account: account, admin_role: role)

          form = Admin::AdminAccounts::UpdateRolesForm.new(role_ids: nil)
          result = described_class.call(account, form)

          assert result.success?
          assert_empty account.reload.role_ids
        end

        it "rejects invalid role_ids" do
          account = create_admin_account
          role = create_admin_role
          create_admin_account_role(admin_account: account, admin_role: role)

          form = Admin::AdminAccounts::UpdateRolesForm.new(role_ids: [role.id, 999_999])
          assert form.invalid?
          assert form.errors.key?(:role_ids)
        end
      end
    end
  end
end
