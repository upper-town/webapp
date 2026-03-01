ApplicationRecordTestFactoryHelper.define(:game, Game,
  name: -> { "Game #{SecureRandom.base58}" },
  slug: -> { "game-#{SecureRandom.base58}" }
)
