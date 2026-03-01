module Admin
  module AdminRoles
    class Update
      include Callable

      class Result < ApplicationResult
        attribute :admin_role
      end

      attr_reader :admin_role, :form

      def initialize(admin_role, form)
        @admin_role = admin_role
        @form = form
      end

      def call
        ids = form.permission_ids
        admin_role.admin_role_permissions.where.not(admin_permission_id: ids).destroy_all

        existing_permission_ids = admin_role.admin_role_permissions.pluck(:admin_permission_id)
        (ids - existing_permission_ids).each do |pid|
          admin_role.admin_role_permissions.create!(admin_permission_id: pid)
        end

        admin_role.touch
        Result.success(admin_role:)
      end
    end
  end
end
