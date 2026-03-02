module Admin
  class DateRangeToDatetimes
    include Callable

    def initialize(start_date: nil, end_date: nil, time_zone: nil)
      @start_date = start_date
      @end_date = end_date
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

      parsed = @time_zone.parse(@start_date.to_s)
      parsed&.beginning_of_day
    rescue ArgumentError, TypeError
      nil
    end

    def parse_end
      return if @end_date.blank?

      parsed = @time_zone.parse(@end_date.to_s)
      parsed&.end_of_day
    rescue ArgumentError, TypeError
      nil
    end
  end
end
