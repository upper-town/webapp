module Filter
  module ByDateRange
    private

    def by_date_range(scope, start_date, end_date, time_zone, column: :created_at, start_time: nil, end_time: nil)
      return scope if start_date.blank? && end_date.blank?

      start_date, end_date = normalize_date_order(start_date, end_date, time_zone)
      datetimes = Admin::DateRangeToDatetimes.call(
        start_date:,
        end_date:,
        start_time:,
        end_time:,
        time_zone:
      )
      range = build_range(datetimes[:start_datetime], datetimes[:end_datetime])
      return scope if range.blank?

      scope.where(column => range)
    end

    def normalize_date_order(start_date, end_date, time_zone)
      return [start_date, end_date] if start_date.blank? || end_date.blank?

      tz = (time_zone.presence && Time.find_zone(time_zone)) || Time.zone
      parsed_start = tz.parse(start_date.to_s)
      parsed_end = tz.parse(end_date.to_s)
      return [end_date, start_date] if parsed_start > parsed_end

      [start_date, end_date]
    rescue ArgumentError, TypeError
      [start_date, end_date]
    end

    def build_range(start_datetime, end_datetime)
      return unless start_datetime || end_datetime

      return (start_datetime..) if start_datetime && !end_datetime
      return (..end_datetime) if end_datetime && !start_datetime

      (start_datetime..end_datetime)
    end
  end
end
