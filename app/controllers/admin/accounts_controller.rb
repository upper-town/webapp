module Admin
  class AccountsController < BaseController
    def index
      @search_term = params[:q]
      @sort_column = params[:sort].presence
      @sort_direction = params[:sort_dir].presence
      relation = Admin::AccountsQuery.call(sort: @sort_column, sort_dir: @sort_direction)
      @pagination = Pagination.new(
        Admin::Queries::AccountsQuery.call(Account, relation, @search_term),
        request,
        per_page: 50
      )
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
