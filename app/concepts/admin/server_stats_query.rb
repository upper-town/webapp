# frozen_string_literal: true

module Admin
  class ServerStatsQuery
    include Callable

    def initialize(server_id: nil, game_id: nil)
      @server_id = server_id
      @game_id = game_id
    end

    def call
      scope = ServerStat.includes(:server, :game)
      scope = scope.where(server_id: @server_id) if @server_id.present?
      scope = scope.where(game_id: @game_id) if @game_id.present?
      scope.order(reference_date: :desc, id: :desc)
    end
  end
end
