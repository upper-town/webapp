module Admin
  class ServerVotesQuery
    include Callable

    # Sentinel in account_ids for votes with no account. Must match Admin::AccountMultiSelectFilterComponent::ANONYMOUS_VALUE.
    ANONYMOUS_VALUE = "anonymous"

    SORT_COLUMNS = {
      "id" => "server_votes.id",
      "created_at" => "server_votes.created_at",
      "remote_ip" => "server_votes.remote_ip"
    }.freeze

    DEFAULT_SORT = { column: "id", direction: :desc }.freeze

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      server_id: nil,
      game_id: nil,
      account_id: nil,
      game_ids: nil,
      server_ids: nil,
      account_ids: nil,
      start_date: nil,
      end_date: nil,
      time_zone: nil,
      sort: nil,
      sort_dir: nil
    )
      @game_ids = normalize_ids(game_ids) || normalize_ids(game_id)
      @server_ids = normalize_ids(server_ids) || normalize_ids(server_id)
      @account_ids = normalize_ids(account_ids) || normalize_ids(account_id)
      @start_date = start_date
      @end_date = end_date
      @time_zone = time_zone
      @sort = sort.presence
      @sort_dir = sort_dir.presence
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      scope = ServerVote.includes(:server, :game, account: :user)
      scope = scope.where(game_id: @game_ids) if @game_ids.present?
      scope = scope.where(server_id: @server_ids) if @server_ids.present?
      scope = apply_account_filter(scope)
      scope = apply_date_range_filter(scope)
      apply_sort(scope)
    end

    private

    def normalize_ids(value)
      Array(value).flatten.map(&:to_s).compact_blank.presence
    end

    def apply_account_filter(scope)
      return scope unless @account_ids.present?

      anonymous_selected = @account_ids.include?(ANONYMOUS_VALUE)
      numeric_ids = @account_ids.reject { |id| id == ANONYMOUS_VALUE }

      if anonymous_selected && numeric_ids.present?
        scope.where(account_id: nil).or(scope.where(account_id: numeric_ids))
      elsif anonymous_selected
        scope.where(account_id: nil)
      else
        scope.where(account_id: numeric_ids)
      end
    end

    def apply_date_range_filter(scope)
      start_date, end_date = normalize_date_order(@start_date, @end_date)
      datetimes = Admin::DateRangeToDatetimes.call(
        start_date: start_date,
        end_date: end_date,
        time_zone: @time_zone
      )
      range = build_created_at_range(datetimes)
      scope = scope.where(created_at: range) if range
      scope
    end

    def normalize_date_order(start_date, end_date)
      return [start_date, end_date] if start_date.blank? || end_date.blank?

      tz = (@time_zone.presence && Time.find_zone(@time_zone)) || Time.zone
      parsed_start = tz.parse(start_date.to_s)
      parsed_end = tz.parse(end_date.to_s)
      return [end_date, start_date] if parsed_start > parsed_end

      [start_date, end_date]
    rescue ArgumentError, TypeError
      [start_date, end_date]
    end

    def build_created_at_range(datetimes)
      start_dt = datetimes[:start_datetime]
      end_dt = datetimes[:end_datetime]
      return (start_dt..) if start_dt && end_dt.nil?
      return (..end_dt) if end_dt && start_dt.nil?
      return (start_dt..end_dt) if start_dt && end_dt

      nil
    end

    def apply_sort(scope)
      column = SORT_COLUMNS[@sort]
      return scope.reorder(SORT_COLUMNS[DEFAULT_SORT[:column]] => DEFAULT_SORT[:direction]) unless column

      direction = @sort_dir.to_s.downcase == "asc" ? :asc : :desc
      scope.reorder(column => direction)
    end
  end
end
