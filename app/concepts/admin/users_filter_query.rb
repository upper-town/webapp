module Admin
  class UsersFilterQuery < Filter::Base
    include Filter::ByDateRange

    ALLOWED_DATE_COLUMNS = %w[created_at updated_at email_confirmed_at locked_at].freeze

    private

    def scopes
      scope = relation
      column = resolve_date_column
      by_date_range(
        scope,
        params[:start_date],
        params[:end_date],
        params[:time_zone],
        column:,
        start_time: params[:start_time],
        end_time: params[:end_time]
      )
    end

    def resolve_date_column
      col = params[:date_column].to_s.presence
      return col.to_sym if col && ALLOWED_DATE_COLUMNS.include?(col)

      :created_at
    end
  end
end
