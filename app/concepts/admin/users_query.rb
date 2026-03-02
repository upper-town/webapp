module Admin
  class UsersQuery
    include Callable

    def initialize(
      search_term: nil,
      relation: nil,
      sort_key: nil,
      sort_dir: nil,
      start_date: nil,
      end_date: nil,
      start_time: nil,
      end_time: nil,
      time_zone: nil,
      date_column: nil
    )
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
      @start_date = start_date
      @end_date = end_date
      @start_time = start_time
      @end_time = end_time
      @time_zone = time_zone
      @date_column = date_column
    end

    def call
      relation = @relation || User.all
      relation = Admin::UsersFilterQuery.call(
        relation,
        start_date: @start_date,
        end_date: @end_date,
        start_time: @start_time,
        end_time: @end_time,
        time_zone: @time_zone,
        date_column: @date_column
      )
      relation = Admin::UsersSearchQuery.call(User, relation, @search_term)
      Admin::UsersSortQuery.call(relation, sort_key: @sort_key, sort_dir: @sort_dir)
    end
  end
end
