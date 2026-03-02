module Admin
  class AdminUsersQuery
    include Callable

    def initialize(search_term: nil, relation: nil, sort_key: nil, sort_dir: nil)
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = @relation || AdminUser
      relation = Admin::AdminUsersSearchQuery.call(AdminUser, relation, @search_term)
      Admin::AdminUsersSortQuery.call(relation, sort_key: @sort_key, sort_dir: @sort_dir)
    end
  end
end
