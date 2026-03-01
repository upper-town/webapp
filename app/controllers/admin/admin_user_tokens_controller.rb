module Admin
  class AdminUserTokensController < BaseController
    def index
      @admin_user = AdminUser.find(params[:id])
      @search_term = params[:q]
      relation = Admin::AdminTokensQuery.new(admin_user_id: @admin_user.id).call
      @pagination = Pagination.new(
        Admin::Queries::AdminTokensQuery.call(AdminToken, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_tokens = @pagination.results
    end
  end
end
