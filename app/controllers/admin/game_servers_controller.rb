module Admin
  class GameServersController < BaseController
    def index
      @game = game_from_params
      @search_term = params[:q]
      @filter_status_ids = params[:status]
      @filter_country_codes = params[:country_codes]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::ServersQuery.call(
        status: @filter_status_ids,
        country_codes: @filter_country_codes,
        search_term: @search_term,
        relation: @game.servers,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @servers = @pagination.results
    end

    private

    def game_from_params
      Game.find(params[:id])
    end
  end
end
