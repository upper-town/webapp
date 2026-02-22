# frozen_string_literal: true

module Admin
  class ServerAccountsController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::ServerAccountsQuery.new(
        server_id: params[:server_id],
        account_id: params[:account_id]
      ).call
      @pagination = Pagination.new(
        Admin::Queries::ServerAccountsQuery.call(ServerAccount, relation, @search_term),
        request,
        per_page: 50
      )
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
