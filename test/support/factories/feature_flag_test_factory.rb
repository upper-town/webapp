ApplicationRecordTestFactoryHelper.define(:feature_flag, FeatureFlag,
  name: -> { "feature_flag_#{SecureRandom.base58}" },
  value: -> { "true" }
)
