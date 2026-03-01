module Admin
  class FeatureFlagsQuery
    include Callable

    def call
      FeatureFlag.order(id: :desc)
    end
  end
end
