module Admin
  class FeatureFlagsQuery
    include Callable

    SORT_COLUMNS = {
      "id" => "feature_flags.id",
      "name" => "feature_flags.name",
      "value" => "feature_flags.value"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    def initialize(sort: nil, sort_dir: nil)
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end

    def call
      column = SORT_COLUMNS[@sort]
      return FeatureFlag.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      FeatureFlag.reorder(column => direction)
    end
  end
end
