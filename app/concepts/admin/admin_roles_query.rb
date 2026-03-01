module Admin
  class AdminRolesQuery
    include Callable

    SORT_COLUMNS = {
      "id" => "admin_roles.id",
      "key" => "admin_roles.key",
      "description" => "admin_roles.description"
    }.freeze

    DEFAULT_SORT = { column: "key", direction: :asc }.freeze

    def initialize(sort: nil, sort_dir: nil)
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      scope = AdminRole.includes(:permissions)
      column = SORT_COLUMNS[@sort]
      return scope.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      scope.reorder(column => direction)
    end
  end
end
