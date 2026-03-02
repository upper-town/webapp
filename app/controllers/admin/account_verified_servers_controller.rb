module Admin
  class AccountVerifiedServersController < BaseController
    def index
      @account = Account.includes(verified_servers: :game).find(params[:id])
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      @servers = Admin::ServersQuery.call(
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir,
        relation: @account.verified_servers.includes(:game)
      )
    end
  end
end
