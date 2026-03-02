module Admin
  class AdminCodesController < BaseController
    def index
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::AdminCodesQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @admin_codes = @pagination.results

      render(status: :ok)
    end

    def show
      @admin_code = admin_code_from_params
    end

    private

    def admin_code_from_params
      AdminCode.includes(:admin_user).find(params[:id])
    end
  end
end
