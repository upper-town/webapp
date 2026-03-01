module Admin
  class ServerAccountsQuery
    include Callable

    def initialize(server_id: nil, account_id: nil)
      @server_id = server_id
      @account_id = account_id
    end

    def call
      scope = ServerAccount.includes(:server, :account, account: :user)
      scope = scope.where(server_id: @server_id) if @server_id.present?
      scope = scope.where(account_id: @account_id) if @account_id.present?
      scope.order(id: :desc)
    end
  end
end
