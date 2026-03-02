module Admin
  class AccountsController < BaseController
    def index
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::AccountsQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @accounts = @pagination.results

      render(status: :ok)
    end

    def show
      @account = account_from_params
    end

    private

    def account_from_params
      Account.includes(:user, verified_servers: :game).find(params[:id])
    end
  end
end
