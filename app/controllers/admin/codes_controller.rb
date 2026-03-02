module Admin
  class CodesController < BaseController
    def index
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::CodesQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @codes = @pagination.results

      render(status: :ok)
    end

    def show
      @code = code_from_params
    end

    private

    def code_from_params
      Code.includes(:user).find(params[:id])
    end
  end
end
