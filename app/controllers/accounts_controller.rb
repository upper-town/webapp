class AccountsController < ApplicationController
  def show
    @account = Account.find(params[:id])
    @account_server_votes_total = account_server_votes_total_query(@account)
    @servers = @account.servers
      .not_archived
      .not_marked_for_deletion
      .includes(:game)
      .order(created_at: :desc)
    @server_stats_hash = Servers::IndexStatsQuery.call(@servers.map(&:id), Time.current)
    @period = Periods::MONTH
  end

  private

  def account_server_votes_total_query(account)
    Rails.cache.fetch(
      "account_server_votes_total:#{account.id}",
      expires_in: 30.seconds
    ) do
      ServerVote.where(account:).count
    end
  end
end
