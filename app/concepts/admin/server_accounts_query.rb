module Admin
  class ServerAccountsQuery
    include Callable

    def initialize(
      server_id: nil,
      account_id: nil,
      search_term: nil,
      relation: nil,
      sort_key: nil,
      sort_dir: nil
    )
      @server_id = server_id
      @account_id = account_id
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = @relation || ServerAccount.includes(:server, :account, account: :user)
        .left_joins(server: :game, account: :user)
      relation = Admin::ServerAccountsFilterQuery.call(
        relation,
        server_id: @server_id,
        account_id: @account_id
      )
      relation = Admin::ServerAccountsSearchQuery.call(ServerAccount, relation, @search_term)
      Admin::ServerAccountsSortQuery.call(relation, sort_key: @sort_key, sort_dir: @sort_dir)
    end
  end
end
