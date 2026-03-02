module Admin
  class AdminPermissionRolesController < BaseController
    def index
      @admin_permission = AdminPermission.includes(roles: :accounts).find(params[:id])
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      @admin_roles = Admin::AdminRolesQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir,
        relation: @admin_permission.roles.includes(:accounts)
      )
    end
  end
end
