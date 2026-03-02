module Admin
  class ServersQuery
    include Callable

    def initialize(
      status: nil,
      country_codes: nil,
      game_ids: nil,
      search_term: nil,
      relation: nil,
      sort_key: nil,
      sort_dir: nil
    )
      @status_ids = Array(status).flatten.map(&:to_s).compact_blank.presence
      @country_codes = Array(country_codes).flatten.map(&:to_s).compact_blank.presence
      @game_ids = Array(game_ids).flatten.map(&:to_s).compact_blank.presence
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = (@relation || Server).includes(:game).left_joins(:game)
      relation = Admin::ServersFilterQuery.call(
        relation,
        status: @status_ids,
        country_codes: @country_codes,
        game_ids: @game_ids
      )
      relation = Admin::ServersSearchQuery.call(Server, relation, @search_term)
      Admin::ServersSortQuery.call(relation, sort_key: @sort_key, sort_dir: @sort_dir)
    end
  end
end
