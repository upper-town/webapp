module Admin
  class ServerAccountsController < BaseController
    def index
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::ServerAccountsQuery.call(
        server_id: params[:server_id],
        account_id: params[:account_id],
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @server_accounts = @pagination.results
      @server = Server.find_by(id: params[:server_id]) if params[:server_id].present?
      @account = Account.find_by(id: params[:account_id]) if params[:account_id].present?

      render(status: :ok)
    end

    def show
      @server_account = server_account_from_params
    end

    private

    def server_account_from_params
      ServerAccount.includes(:server, :account, account: :user).find(params[:id])
    end
  end
end
