module Admin
  class GamesQuery
    include Callable

    SORT_COLUMNS = {
      "id" => "games.id",
      "name" => "games.name",
      "slug" => "games.slug",
      "site_url" => "games.site_url"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    def initialize(sort: nil, sort_dir: nil)
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      column = SORT_COLUMNS[@sort]
      return Game.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      Game.reorder(column => direction)
    end
  end
end
