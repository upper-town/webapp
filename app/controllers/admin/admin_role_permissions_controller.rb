module Admin
  class AdminRolePermissionsController < BaseController
    def index
      @admin_role = AdminRole.includes(:permissions).find(params[:id])
      @search_term = params[:q]
      relation = @admin_role.permissions.order(id: :asc)
      @admin_permissions = Admin::Queries::AdminPermissionsQuery.call(AdminPermission, relation, @search_term)
    end
  end
end
