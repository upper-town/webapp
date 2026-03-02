module Admin
  class ServerStatsQuery
    include Callable

    SORT_COLUMNS = {
      "id" => "server_stats.id",
      "server" => "servers.name",
      "game" => "games.name",
      "period" => "server_stats.period",
      "reference_date" => "server_stats.reference_date",
      "vote_count" => "server_stats.vote_count",
      "ranking_number" => "server_stats.ranking_number",
      "created_at" => "server_stats.created_at"
    }.freeze

    DEFAULT_SORT = { column: "reference_date", direction: :desc }.freeze

    def initialize(server_id: nil, game_id: nil, period: nil, periods: nil, sort: nil, sort_dir: nil)
      @server_id = server_id
      @game_id = game_id
      @periods = Array(periods || period).flatten.map(&:to_s).compact_blank.presence
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      scope = ServerStat.includes(:server, :game).left_joins(:server, :game)
      scope = scope.where(server_id: @server_id) if @server_id.present?
      scope = scope.where(game_id: @game_id) if @game_id.present?
      scope = scope.where(period: @periods) if @periods.present?
      apply_sort(scope)
    end

    private

    def apply_sort(scope)
      column = SORT_COLUMNS[@sort]
      return scope.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction], id: :desc) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      scope.reorder(column => direction, id: :desc)
    end
  end
end
