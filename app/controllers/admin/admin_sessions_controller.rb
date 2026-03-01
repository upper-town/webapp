module Admin
  class AdminSessionsController < BaseController
    def index
      @search_term = params[:q]
      relation = AdminSession.includes(:admin_user).order(id: :desc)
      @pagination = Pagination.new(
        Admin::Queries::AdminSessionsQuery.call(AdminSession, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_sessions = @pagination.results

      render(status: :ok)
    end

    def show
      @admin_session = admin_session_from_params
    end

    private

    def admin_session_from_params
      AdminSession.includes(:admin_user).find(params[:id])
    end
  end
end
