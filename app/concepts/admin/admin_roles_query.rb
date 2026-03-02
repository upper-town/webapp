module Admin
  class AdminRolesQuery
    include Callable

    def initialize(search_term: nil, relation: nil, sort_key: nil, sort_dir: nil)
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = @relation || AdminRole.includes(:permissions)
      relation = Admin::AdminRolesSearchQuery.call(AdminRole, relation, @search_term)
      Admin::AdminRolesSortQuery.call(
        relation,
        sort_key: @sort_key.presence || "key",
        sort_dir: @sort_dir.presence || "asc"
      )
    end
  end
end
