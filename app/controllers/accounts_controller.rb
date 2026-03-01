class AccountsController < ApplicationController
  def show
    @account = Account.find(params[:id])
    @account_server_votes_total = account_server_votes_total_query(@account)
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
