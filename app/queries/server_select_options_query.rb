class ServerSelectOptionsQuery
  include Callable

  CACHE_KEY = "server_select_options_query"
  CACHE_EXPIRES_IN = 5.minutes

  attr_reader(
    :only_with_votes,
    :cache_enabled,
    :cache_key,
    :cache_expires_in
  )

  def initialize(
    only_with_votes: false,
    cache_enabled: true,
    cache_key: CACHE_KEY,
    cache_expires_in: CACHE_EXPIRES_IN
  )
    @only_with_votes = only_with_votes
    @cache_enabled = cache_enabled
    @cache_key = "#{cache_key}#{':only_with_votes' if only_with_votes}"
    @cache_expires_in = cache_expires_in
  end

  def call
    with_cache_if_enabled do
      server_query
    end
  end

  private

  def server_query
    scope = Server.all
    scope = scope.joins(:votes) if only_with_votes

    scope
      .order("servers.name": :asc)
      .distinct
      .pluck("servers.name", "servers.id")
  end

  def with_cache_if_enabled(&)
    if cache_enabled
      Rails.cache.fetch(cache_key, expires_in: cache_expires_in, &)
    else
      yield
    end
  end
end
