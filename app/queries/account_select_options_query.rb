class AccountSelectOptionsQuery
  include Callable

  CACHE_KEY = "account_select_options_query"
  CACHE_EXPIRES_IN = 5.minutes
  DEFAULT_LIMIT = 50

  attr_reader(
    :only_with_votes,
    :cache_enabled,
    :cache_key,
    :cache_expires_in,
    :search_term,
    :ids,
    :limit
  )

  def initialize(
    only_with_votes: false,
    cache_enabled: true,
    cache_key: CACHE_KEY,
    cache_expires_in: CACHE_EXPIRES_IN,
    search_term: nil,
    ids: nil,
    limit: DEFAULT_LIMIT
  )
    @only_with_votes = only_with_votes
    @cache_enabled = cache_enabled
    @cache_key = "#{cache_key}#{':only_with_votes' if only_with_votes}"
    @cache_expires_in = cache_expires_in
    @search_term = search_term&.squish
    @ids = Array(ids).flatten.map(&:to_s).compact_blank.presence
    @limit = limit.to_i.positive? ? limit.to_i : DEFAULT_LIMIT
  end

  def call
    if search_term.present? || ids.present?
      account_query
    else
      with_cache_if_enabled { account_query }
    end
  end

  # Returns array of [label, id] for form selects.
  def self.options_for_select(**)
    new(**).call
  end

  private

  def account_query
    scope = Account.joins(:user).order("users.email": :asc)
    scope = scope.joins(:server_votes) if only_with_votes

    scope = apply_search(scope)
    scope = scope.where(accounts: { id: ids }) if ids.present?
    scope = scope.limit(limit) if search_term.present? || ids.present?

    scope
      .distinct
      .pluck("users.email", "accounts.id")
  end

  def apply_search(scope)
    return scope if search_term.blank?

    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(search_term)}%"
    scope.where("users.email ILIKE ?", pattern)
  end

  def with_cache_if_enabled(&)
    if cache_enabled
      Rails.cache.fetch(cache_key, expires_in: cache_expires_in, &)
    else
      yield
    end
  end
end
