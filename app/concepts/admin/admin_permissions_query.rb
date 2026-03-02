module Admin
  class AdminPermissionsQuery
    include Callable

    def initialize(search_term: nil, relation: nil, sort_key: nil, sort_dir: nil)
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = @relation || AdminPermission.includes(:roles)
      relation = Admin::AdminPermissionsSearchQuery.call(AdminPermission, relation, @search_term)
      Admin::AdminPermissionsSortQuery.call(
        relation,
        sort_key: @sort_key.presence || "key",
        sort_dir: @sort_dir.presence || "asc"
      )
    end
  end
end
