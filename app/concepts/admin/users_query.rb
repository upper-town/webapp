module Admin
  class UsersQuery
    include Callable

    SORT_COLUMNS = {
      "id" => "users.id",
      "email" => "users.email",
      "email_confirmed_at" => "users.email_confirmed_at",
      "locked_at" => "users.locked_at"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    def initialize(sort: nil, sort_dir: nil)
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      column = SORT_COLUMNS[@sort]
      return User.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      User.reorder(column => direction)
    end
  end
end
