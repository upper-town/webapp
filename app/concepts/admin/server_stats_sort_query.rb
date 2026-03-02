module Admin
  class ServerStatsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "server_stats.id",
        "server" => "servers.name",
        "game" => "games.name",
        "period" => "server_stats.period",
        "reference_date" => "server_stats.reference_date",
        "vote_count" => "server_stats.vote_count",
        "ranking_number" => "server_stats.ranking_number",
        "created_at" => "server_stats.created_at"
      }
    end
  end
end
