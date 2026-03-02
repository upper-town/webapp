module Admin
  class AdminUserSessionsController < BaseController
    def index
      @admin_user = AdminUser.find(params[:id])
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::AdminSessionsQuery.call(
        admin_user_id: @admin_user.id,
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @admin_sessions = @pagination.results
    end
  end
end
