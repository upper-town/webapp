module Admin
  class CodesQuery
    include Callable

    def initialize(
      user_id: nil,
      search_term: nil,
      relation: nil,
      sort_key: nil,
      sort_dir: nil
    )
      @user_id = user_id
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = @relation || Code.includes(:user)
      relation = Admin::CodesFilterQuery.call(relation, user_id: @user_id)
      relation = Admin::CodesSearchQuery.call(Code, relation, @search_term)
      Admin::CodesSortQuery.call(relation, sort_key: @sort_key, sort_dir: @sort_dir)
    end
  end
end
