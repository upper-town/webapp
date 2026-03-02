module Admin
  class SessionsController < BaseController
    def index
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::SessionsQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @sessions = @pagination.results

      render(status: :ok)
    end

    def show
      @session = session_from_params
    end

    private

    def session_from_params
      Session.includes(:user).find(params[:id])
    end
  end
end
