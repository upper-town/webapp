# frozen_string_literal: true

module Admin
  class GameServersController < BaseController
    def index
      @game = game_from_params
      @search_term = params[:q]
      relation = @game.servers.includes(:game).order(id: :desc)
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
