module Admin
  class AdminUserTokensController < BaseController
    def index
      @admin_user = AdminUser.find(params[:id])
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::AdminTokensQuery.call(
        admin_user_id: @admin_user.id,
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @admin_tokens = @pagination.results
    end
  end
end
