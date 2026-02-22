# frozen_string_literal: true

module Admin
  class DashboardStats
    include Callable

    def call
      {
        users_count: User.count,
        users_locked_count: User.where.not(locked_at: nil).count,
        admin_users_count: AdminUser.count,
        admin_users_locked_count: AdminUser.where.not(locked_at: nil).count,
        accounts_count: Account.count,
        admin_accounts_count: AdminAccount.count,
        games_count: Game.count,
        feature_flags_count: FeatureFlag.count,
        webhook_configs_count: WebhookConfig.count,
        webhook_events_count: WebhookEvent.count,
        servers_count: Server.count,
        servers_verified_count: Server.verified.count,
        servers_archived_count: Server.archived.count,
        servers_marked_for_deletion_count: Server.marked_for_deletion.count,
      }
    end
  end
end
