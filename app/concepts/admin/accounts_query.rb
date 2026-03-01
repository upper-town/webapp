module Admin
  class AccountsQuery
    include Callable

    SORT_COLUMNS = {
      "id" => "accounts.id",
      "uuid" => "accounts.uuid",
      "created_at" => "accounts.created_at"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    def initialize(sort: nil, sort_dir: nil)
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      scope = Account.includes(:user, :verified_servers)
      column = SORT_COLUMNS[@sort]
      return scope.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      scope.reorder(column => direction)
    end
  end
end
