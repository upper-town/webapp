module Admin
  class AccountVerifiedServersController < BaseController
    def index
      @account = Account.includes(verified_servers: :game).find(params[:id])
      @search_term = params[:q]
      relation = @account.verified_servers.includes(:game).order(id: :asc)
      @servers = Admin::Queries::ServersQuery.call(Server, relation, @search_term)
    end
  end
end
