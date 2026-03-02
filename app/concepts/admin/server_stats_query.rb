module Admin
  class ServerStatsQuery
    include Callable

    def initialize(
      server_id: nil,
      game_id: nil,
      period: nil,
      periods: nil,
      search_term: nil,
      relation: nil,
      sort_key: nil,
      sort_dir: nil
    )
      @server_id = server_id
      @game_id = game_id
      @periods = Array(periods || period).flatten.map(&:to_s).compact_blank.presence
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      scope = @relation || ServerStat.includes(:server, :game).left_joins(:server, :game)
      scope = Admin::ServerStatsFilterQuery.call(
        scope,
        server_id: @server_id,
        game_id: @game_id,
        periods: @periods
      )
      scope = Admin::ServerStatsSearchQuery.call(ServerStat, scope, @search_term)
      Admin::ServerStatsSortQuery.call(
        scope,
        sort_key: @sort_key.presence || "reference_date",
        sort_dir: @sort_dir.presence || "desc"
      )
    end
  end
end
