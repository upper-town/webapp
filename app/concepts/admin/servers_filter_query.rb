module Admin
  class ServersFilterQuery < Filter::Base
    include Filter::ByValues

    STATUS_SCOPES = {
      "verified" => :verified,
      "not_verified" => :not_verified,
      "archived" => :archived,
      "not_archived" => :not_archived,
      "marked_for_deletion" => :marked_for_deletion
    }.freeze

    private

    def scopes
      scope = relation
      scope = by_status(scope)
      scope = by_values(scope, params[:country_codes], column: :country_code)
      by_values(scope, params[:game_ids], column: :game_id)
    end

    def by_status(scope)
      status_ids = Array(params[:status]).flatten.map(&:to_s).compact_blank.presence
      return scope unless status_ids.present?

      scopes = status_ids.filter_map { |s| STATUS_SCOPES[s] }.uniq
      return scope if scopes.empty?

      scopes.map { |scope_name| scope.public_send(scope_name) }.reduce(:or)
    end
  end
end
