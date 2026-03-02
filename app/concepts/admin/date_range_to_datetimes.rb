module Admin
  class DateRangeToDatetimes
    include Callable

    # HH:MM or HH:MM:SS. Invalid values (e.g. 24:00, 99:99) fall through to beginning_of_day/end_of_day.
    TIME_PATTERN = /\A(\d{1,2}):(\d{2})(?::(\d{2}))?\z/

    def initialize(start_date: nil, end_date: nil, start_time: nil, end_time: nil, time_zone: nil)
      @start_date = start_date
      @end_date = end_date
      @start_time = start_time&.to_s&.strip
      @end_time = end_time&.to_s&.strip
      @time_zone = (time_zone.presence && Time.find_zone(time_zone)) || Time.zone
    end

    def call
      {
        start_datetime: parse_start, end_datetime: parse_end
      }
    end

    private

    def parse_start
      return if @start_date.blank?

      base = @time_zone.parse(@start_date.to_s)
      return unless base

      if @start_time.present? && (m = @start_time.match(TIME_PATTERN))
        h = m[1].to_i
        min = m[2].to_i
        s = (m[3] || 0).to_i
        return base.change(hour: h, min:, sec: s) if h <= 23 && min <= 59 && s <= 59
      end
      base.beginning_of_day
    rescue ArgumentError, TypeError
      nil
    end

    def parse_end
      return if @end_date.blank?

      base = @time_zone.parse(@end_date.to_s)
      return unless base

      if @end_time.present? && (m = @end_time.match(TIME_PATTERN))
        h = m[1].to_i
        min = m[2].to_i
        s = (m[3] || 0).to_i
        return base.change(hour: h, min:, sec: s) if h <= 23 && min <= 59 && s <= 59
      end
      base.end_of_day
    rescue ArgumentError, TypeError
      nil
    end
  end
end
