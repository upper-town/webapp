module Admin
  class ServerAccountsFilterQuery < Filter::Base
    include Filter::ByValues

    private

    def scopes
      scope = relation
      scope = by_values(scope, params[:server_id], column: :server_id)
      by_values(scope, params[:account_id], column: :account_id)
    end
  end
end
