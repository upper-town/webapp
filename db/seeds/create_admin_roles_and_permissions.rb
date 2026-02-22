# frozen_string_literal: true

module Seeds
  class CreateAdminRolesAndPermissions
    include Callable

    def call
      jobs_access = AdminPermission.find_or_create_by!(key: AdminPermission::JOBS_ACCESS) do |p|
        p.description = "Access to Mission Control Jobs UI"
      end

      admin_role = AdminRole.find_or_create_by!(key: "admin") do |r|
        r.description = "Full admin access"
      end
      AdminRolePermission.find_or_create_by!(admin_role:, admin_permission: jobs_access)

      []
    end
  end
end
