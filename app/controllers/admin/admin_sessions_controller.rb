module Admin
  class AdminSessionsController < BaseController
    def index
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::AdminSessionsQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
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
