module Admin
  class ServerVotesQuery
    include Callable

    # Sentinel in account_ids for votes with no account. Must match Admin::AccountMultiSelectFilterComponent::ANONYMOUS_VALUE.
    ANONYMOUS_VALUE = "anonymous"

    SORT_COLUMNS = {
      "id" => "server_votes.id",
      "created_at" => "server_votes.created_at",
      "remote_ip" => "server_votes.remote_ip"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    def initialize(
      server_id: nil,
      game_id: nil,
      account_id: nil,
      game_ids: nil,
      server_ids: nil,
      account_ids: nil,
      sort: nil,
      sort_dir: nil
    )
      @game_ids = normalize_ids(game_ids) || normalize_ids(game_id)
      @server_ids = normalize_ids(server_ids) || normalize_ids(server_id)
      @account_ids = normalize_ids(account_ids) || normalize_ids(account_id)
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      scope = ServerVote.includes(:server, :game, account: :user)
      scope = scope.where(game_id: @game_ids) if @game_ids.present?
      scope = scope.where(server_id: @server_ids) if @server_ids.present?
      scope = apply_account_filter(scope)
      apply_sort(scope)
    end

    private

    def normalize_ids(value)
      Array(value).flatten.map(&:to_s).compact_blank.presence
    end

    def apply_account_filter(scope)
      return scope unless @account_ids.present?

      anonymous_selected = @account_ids.include?(ANONYMOUS_VALUE)
      numeric_ids = @account_ids.reject { |id| id == ANONYMOUS_VALUE }

      if anonymous_selected && numeric_ids.present?
        scope.where(account_id: nil).or(scope.where(account_id: numeric_ids))
      elsif anonymous_selected
        scope.where(account_id: nil)
      else
        scope.where(account_id: numeric_ids)
      end
    end

    def apply_sort(scope)
      column = SORT_COLUMNS[@sort]
      return scope.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      scope.reorder(column => direction)
    end
  end
end
