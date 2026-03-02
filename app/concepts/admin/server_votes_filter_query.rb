module Admin
  class ServerVotesFilterQuery < Filter::Base
    include Filter::ByDateRange
    include Filter::ByValues

    ANONYMOUS_VALUE = "anonymous"

    private

    def scopes
      scope = relation
      scope = by_values(scope, params[:game_ids], column: :game_id)
      scope = by_values(scope, params[:server_ids], column: :server_id)
      scope = by_account(scope)
      by_date_range(scope, params[:start_date], params[:end_date], params[:time_zone], column: :created_at)
    end

    def by_account(scope)
      account_ids = Array(params[:account_ids]).flatten.map(&:to_s).compact_blank.presence
      return scope unless account_ids.present?

      anonymous_selected = account_ids.include?(ANONYMOUS_VALUE)
      numeric_ids = account_ids.reject { |id| id == ANONYMOUS_VALUE }

      if anonymous_selected && numeric_ids.present?
        scope.where(account_id: nil).or(scope.where(account_id: numeric_ids))
      elsif anonymous_selected
        scope.where(account_id: nil)
      else
        scope.where(account_id: numeric_ids)
      end
    end
  end
end
