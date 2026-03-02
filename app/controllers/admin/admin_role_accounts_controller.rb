module Admin
  class AdminRoleAccountsController < BaseController
    def index
      @admin_role = admin_role_from_params
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::AdminAccountsQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir,
        relation: @admin_role.accounts.includes(:admin_user, :roles)
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @admin_accounts = @pagination.results
    end

    private

    def admin_role_from_params
      AdminRole.find(params[:id])
    end
  end
end
