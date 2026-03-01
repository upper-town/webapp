module Admin
  class AdminUserSessionsController < BaseController
    def index
      @admin_user = AdminUser.find(params[:id])
      @search_term = params[:q]
      relation = AdminSession.where(admin_user_id: @admin_user.id).includes(:admin_user).order(id: :desc)
      @pagination = Pagination.new(
        Admin::Queries::AdminSessionsQuery.call(AdminSession, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_sessions = @pagination.results
    end
  end
end
