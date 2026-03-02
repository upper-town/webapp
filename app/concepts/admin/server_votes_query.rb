module Admin
  class ServerVotesQuery
    include Callable

    ANONYMOUS_VALUE = ServerVotesFilterQuery::ANONYMOUS_VALUE

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      server_id: nil,
      game_id: nil,
      account_id: nil,
      game_ids: nil,
      server_ids: nil,
      account_ids: nil,
      start_date: nil,
      end_date: nil,
      time_zone: nil,
      search_term: nil,
      relation: nil,
      sort_key: nil,
      sort_dir: nil
    )
      @game_ids = normalize_ids(game_ids) || normalize_ids(game_id)
      @server_ids = normalize_ids(server_ids) || normalize_ids(server_id)
      @account_ids = normalize_ids(account_ids) || normalize_ids(account_id)
      @start_date = start_date
      @end_date = end_date
      @time_zone = time_zone
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      scope = @relation || ServerVote.includes(:server, :game, account: :user)
      scope = Admin::ServerVotesFilterQuery.call(
        scope,
        game_ids: @game_ids,
        server_ids: @server_ids,
        account_ids: @account_ids,
        start_date: @start_date,
        end_date: @end_date,
        time_zone: @time_zone
      )
      scope = Admin::ServerVotesSearchQuery.call(ServerVote, scope, @search_term)
      Admin::ServerVotesSortQuery.call(scope, sort_key: @sort_key, sort_dir: @sort_dir)
    end

    private

    def normalize_ids(value)
      Array(value).flatten.map(&:to_s).compact_blank.presence
    end
  end
end
