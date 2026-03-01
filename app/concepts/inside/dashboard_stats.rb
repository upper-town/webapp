# frozen_string_literal: true

module Inside
  class DashboardStats
    include Callable

    def initialize(account)
      @account = account
    end

    def call
      {
        servers_count: @account.servers.count,
        servers_verified_count: @account.verified_servers.count,
        servers_pending_count: @account.servers.not_verified.count,
        servers_archived_count: @account.servers.archived.count,
        server_votes_count: @account.server_votes.count
      }
    end
  end
end
