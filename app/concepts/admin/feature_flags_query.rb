module Admin
  class FeatureFlagsQuery
    include Callable

    def initialize(search_term: nil, relation: nil, sort_key: nil, sort_dir: nil)
      @search_term = search_term&.squish
      @relation = relation
      @sort_key = sort_key.presence
      @sort_dir = sort_dir.presence
    end

    def call
      relation = @relation || FeatureFlag
      relation = Admin::FeatureFlagsSearchQuery.call(FeatureFlag, relation, @search_term)
      Admin::FeatureFlagsSortQuery.call(relation, sort_key: @sort_key, sort_dir: @sort_dir)
    end
  end
end
