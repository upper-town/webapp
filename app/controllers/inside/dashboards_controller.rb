module Inside
  class DashboardsController < BaseController
    RECENT_SERVERS_LIMIT = 5

    def show
      @stats = Inside::DashboardStats.call(current_account)

      recent_servers = current_account.servers
        .not_archived
        .not_marked_for_deletion
        .includes(:game)
        .limit(RECENT_SERVERS_LIMIT)
        .to_a

      @recent_servers = recent_servers
      @recent_server_stats_hash = Servers::IndexStatsQuery.call(
        recent_servers.map(&:id),
        Time.current
      )
      @period = Periods::MONTH
    end
  end
end
