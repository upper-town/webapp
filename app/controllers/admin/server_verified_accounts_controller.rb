module Admin
  class ServerVerifiedAccountsController < BaseController
    def index
      @server = Server.includes(verified_accounts: :user).find(params[:id])
      @search_term = params[:q]
      relation = @server.verified_accounts.includes(:user).order(id: :asc)
      @accounts = Admin::Queries::AccountsQuery.call(Account, relation, @search_term)
    end
  end
end
