module Admin
  class ServersQuery
    include Callable

    STATUS_SCOPES = {
      "verified" => :verified,
      "not_verified" => :not_verified,
      "archived" => :archived,
      "not_archived" => :not_archived,
      "marked_for_deletion" => :marked_for_deletion
    }.freeze

    SORT_COLUMNS = {
      "id" => "servers.id",
      "name" => "servers.name",
      "game" => "games.name",
      "site_url" => "servers.site_url",
      "country" => "servers.country_code",
      "status" => "servers.verified_at"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    def initialize(status: nil, country_code: nil, country_codes: nil, game_ids: nil, relation: nil, sort: nil, sort_dir: nil)
      @status_ids = Array(status).flatten.map(&:to_s).compact_blank.presence
      @country_codes = Array(country_codes || country_code).flatten.map(&:to_s).compact_blank.presence
      @game_ids = Array(game_ids).flatten.map(&:to_s).compact_blank.presence
      @relation = relation
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = (@relation || Server).includes(:game).left_joins(:game)
      relation = apply_status_filter(relation)
      relation = apply_country_filter(relation)
      relation = apply_game_ids_filter(relation)
      apply_sort(relation)
    end

    private

    def apply_status_filter(relation)
      return relation unless @status_ids.present?

      scopes = @status_ids.filter_map { |s| STATUS_SCOPES[s] }.uniq
      return relation if scopes.empty?

      scopes.map { |scope_name| relation.public_send(scope_name) }.reduce(:or)
    end

    def apply_country_filter(relation)
      return relation unless @country_codes.present?

      relation.where(country_code: @country_codes)
    end

    def apply_game_ids_filter(relation)
      return relation unless @game_ids.present?

      relation.where(game_id: @game_ids)
    end

    def apply_sort(relation)
      column = SORT_COLUMNS[@sort]
      return relation.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      relation.reorder(column => direction)
    end
  end
end
