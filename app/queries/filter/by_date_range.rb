module Filter
  module ByDateRange
    private

    def by_date_range(scope, start_date, end_date, time_zone, column: :created_at, start_time: nil, end_time: nil)
      start_date, end_date = normalize_date_order(start_date, end_date, time_zone)
      datetimes = Admin::DateRangeToDatetimes.call(
        start_date:,
        end_date:,
        start_time:,
        end_time:,
        time_zone:
      )
      range = build_range(datetimes)
      return scope unless range

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

    def build_range(datetimes)
      start_dt = datetimes[:start_datetime]
      end_dt = datetimes[:end_datetime]
      return (start_dt..) if start_dt && end_dt.nil?
      return (..end_dt) if end_dt && start_dt.nil?
      return (start_dt..end_dt) if start_dt && end_dt

      nil
    end
  end
end
