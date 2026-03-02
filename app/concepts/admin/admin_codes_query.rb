module Admin
  class AdminCodesQuery
    include Callable

    def initialize(
      admin_user_id: nil,
      search_term: nil,
      relation: nil,
      sort_key: nil,
      sort_dir: nil
    )
      @admin_user_id = admin_user_id
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = @relation || AdminCode.includes(:admin_user)
      relation = Admin::AdminCodesFilterQuery.call(relation, admin_user_id: @admin_user_id)
      relation = Admin::AdminCodesSearchQuery.call(AdminCode, relation, @search_term)
      Admin::AdminCodesSortQuery.call(relation, sort_key: @sort_key, sort_dir: @sort_dir)
    end
  end
end
