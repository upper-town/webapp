module Admin
  class FeatureFlagsSortQuery < Sort::Base
    private

    def sort_key_columns
      {
        "id" => "feature_flags.id",
        "name" => "feature_flags.name",
        "value" => "feature_flags.value"
      }
    end
  end
end
