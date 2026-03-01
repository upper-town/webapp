ApplicationRecordTestFactoryHelper.define(:admin_role, AdminRole,
  key: -> { "admin_role_key_#{SecureRandom.base58}" },
  description: -> { "AdminRole description" }
)
