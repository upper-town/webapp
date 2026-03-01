module Admin
  class AdminAccountsQuery
    include Callable

    SORT_COLUMNS = {
      "id" => "admin_accounts.id",
      "created_at" => "admin_accounts.created_at"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    def initialize(sort: nil, sort_dir: nil)
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      scope = AdminAccount.includes(:admin_user, :roles)
      column = SORT_COLUMNS[@sort]
      return scope.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      scope.reorder(column => direction)
    end
  end
end
