ApplicationRecordTestFactoryHelper.define(:account, Account,
  user: -> { build_user }
)
