module Admin
  class ServerVotesQuery
    include Callable

    SORT_COLUMNS = {
      "id" => "server_votes.id",
      "created_at" => "server_votes.created_at",
      "remote_ip" => "server_votes.remote_ip"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    def initialize(server_id: nil, game_id: nil, account_id: nil, sort: nil, sort_dir: nil)
      @server_id = server_id
      @game_id = game_id
      @account_id = account_id
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      scope = ServerVote.includes(:server, :game, account: :user)
      scope = scope.where(server_id: @server_id) if @server_id.present?
      scope = scope.where(game_id: @game_id) if @game_id.present?
      scope = scope.where(account_id: @account_id) if @account_id.present?
      apply_sort(scope)
    end

    private

    def apply_sort(scope)
      column = SORT_COLUMNS[@sort]
      return scope.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      scope.reorder(column => direction)
    end
  end
end
