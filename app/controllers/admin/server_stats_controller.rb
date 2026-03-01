module Admin
  class ServerStatsController < BaseController
    def index
      @search_term = params[:q]
      @filter_period = params[:period]
      @sort_column = params[:sort].presence
      @sort_direction = params[:sort_dir].presence
      relation = Admin::ServerStatsQuery.call(
        server_id: params[:server_id],
        game_id: params[:game_id],
        period: @filter_period,
        sort: @sort_column,
        sort_dir: @sort_direction
      )
      @pagination = Pagination.new(
        Admin::Queries::ServerStatsQuery.call(ServerStat, relation, @search_term),
        request,
        per_page: 50
      )
      @server_stats = @pagination.results
      @server = Server.find_by(id: params[:server_id]) if params[:server_id].present?
      @game = Game.find_by(id: params[:game_id]) if params[:game_id].present?

      render(status: :ok)
    end

    def show
      @server_stat = server_stat_from_params
    end

    private

    def server_stat_from_params
      ServerStat.includes(:server, :game).find(params[:id])
    end
  end
end
