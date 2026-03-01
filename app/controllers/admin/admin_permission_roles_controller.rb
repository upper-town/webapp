module Admin
  class AdminPermissionRolesController < BaseController
    def index
      @admin_permission = AdminPermission.includes(roles: :accounts).find(params[:id])
      @search_term = params[:q]
      relation = @admin_permission.roles.includes(:accounts).order(id: :asc)
      @admin_roles = Admin::Queries::AdminRolesQuery.call(AdminRole, relation, @search_term)
    end
  end
end
