module Admin
  class AdminRolePermissionsController < BaseController
    def index
      @admin_role = AdminRole.includes(:permissions).find(params[:id])
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      @admin_permissions = Admin::AdminPermissionsQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir,
        relation: @admin_role.permissions
      )
    end
  end
end
