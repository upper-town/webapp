module Admin
  class ServerStatsController < BaseController
    def index
      @search_term = params[:q]
      @filter_periods = params[:periods]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::ServerStatsQuery.call(
        server_id: params[:server_id],
        game_id: params[:game_id],
        periods: @filter_periods,
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
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
