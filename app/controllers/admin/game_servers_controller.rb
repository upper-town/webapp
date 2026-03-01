module Admin
  class GameServersController < BaseController
    def index
      @game = game_from_params
      @search_term = params[:q]
      @filter_status = params[:status]
      @filter_country_code = params[:country_code]
      @sort_column = params[:sort].presence
      @sort_direction = params[:sort_dir].presence
      relation = Admin::ServersQuery.call(
        status: @filter_status,
        country_code: @filter_country_code,
        relation: @game.servers,
        sort: @sort_column,
        sort_dir: @sort_direction
      )
      @pagination = Pagination.new(
        Admin::Queries::ServersQuery.call(Server, relation, @search_term),
        request,
        per_page: 50
      )
      @servers = @pagination.results
    end

    private

    def game_from_params
      Game.find(params[:id])
    end
  end
end
