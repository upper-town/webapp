module Admin
  class AdminTokensController < BaseController
    def index
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::AdminTokensQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @admin_tokens = @pagination.results

      render(status: :ok)
    end

    def show
      @admin_token = admin_token_from_params
    end

    private

    def admin_token_from_params
      AdminToken.includes(:admin_user).find(params[:id])
    end
  end
end
