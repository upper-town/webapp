module Admin
  class AdminUsersQuery
    include Callable

    SORT_COLUMNS = {
      "id" => "admin_users.id",
      "email" => "admin_users.email",
      "email_confirmed_at" => "admin_users.email_confirmed_at",
      "locked_at" => "admin_users.locked_at"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    def initialize(sort: nil, sort_dir: nil)
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      column = SORT_COLUMNS[@sort]
      return AdminUser.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      AdminUser.reorder(column => direction)
    end
  end
end
