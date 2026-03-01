module Admin
  class AdminRoleAccountsController < BaseController
    def index
      @admin_role = admin_role_from_params
      @search_term = params[:q]
      relation = @admin_role.accounts.includes(:admin_user, :roles).order(id: :desc)
      @pagination = Pagination.new(
        Admin::Queries::AdminAccountsQuery.call(AdminAccount, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_accounts = @pagination.results
    end

    private

    def admin_role_from_params
      AdminRole.find(params[:id])
    end
  end
end
