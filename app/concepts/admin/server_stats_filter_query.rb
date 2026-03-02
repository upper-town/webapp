module Admin
  class ServerStatsFilterQuery < Filter::Base
    include Filter::ByValues

    private

    def scopes
      scope = relation
      scope = by_values(scope, params[:server_id], column: :server_id)
      scope = by_values(scope, params[:game_id], column: :game_id)
      by_values(scope, params[:periods], column: :period)
    end
  end
end
