module Admin
  class AdminUserRolesController < BaseController
    def index
      @admin_user = AdminUser.includes(account: :roles).find(params[:id])
      @search_term = params[:q]
      relation = (@admin_user.account&.roles || AdminRole.none).order(id: :asc)
      @admin_roles = Admin::Queries::AdminRolesQuery.call(AdminRole, relation, @search_term)
    end
  end
end
