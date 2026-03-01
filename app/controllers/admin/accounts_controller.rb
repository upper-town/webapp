module Admin
  class AccountsController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::AccountsQuery.new.call
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
