module Admin
  class DateRangeFilterComponent < ApplicationComponent
    DEFAULT_SELECT_CLASS = "form-select admin-servers-filter-inline__select btn"

    attr_reader :form, :start_date, :end_date, :start_time, :end_time, :time_zone,
                :time_zone_param_present, :show_time_zone, :show_time, :param_prefix, :request,
                :show_date_column, :date_column, :date_column_options

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      form:,
      start_date: nil,
      end_date: nil,
      start_time: nil,
      end_time: nil,
      time_zone: nil,
      time_zone_param_present: false,
      show_time_zone: false,
      show_time: false,
      param_prefix: nil,
      request: nil,
      show_date_column: false,
      date_column: nil,
      date_column_options: []
    )
      super()

      @form = form
      @start_date = start_date
      @end_date = end_date
      @start_time = start_time
      @end_time = end_time
      @time_zone = time_zone
      @time_zone_param_present = time_zone_param_present
      @show_time_zone = show_time_zone
      @show_time = show_time
      @param_prefix = param_prefix
      @request = request
      @show_date_column = show_date_column
      @date_column = date_column
      @date_column_options = date_column_options
    end
    # rubocop:enable Metrics/ParameterLists

    def date_column_param
      param_prefix.present? ? "#{param_prefix}_date_column" : "date_column"
    end

    def start_date_param
      param_prefix.present? ? "#{param_prefix}_start_date" : "start_date"
    end

    def end_date_param
      param_prefix.present? ? "#{param_prefix}_end_date" : "end_date"
    end

    def time_zone_param
      param_prefix.present? ? "#{param_prefix}_time_zone" : "time_zone"
    end

    def start_time_param
      param_prefix.present? ? "#{param_prefix}_start_time" : "start_time"
    end

    def end_time_param
      param_prefix.present? ? "#{param_prefix}_end_time" : "end_time"
    end

    def time_zone_options
      @time_zone_options ||= TimeZoneSelectOptionsQuery.call(selected_time_zone: time_zone)
    end

    def format_date_for_input(value)
      return if value.blank?

      if value.is_a?(String) && value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
        value
      elsif value.respond_to?(:to_date)
        value.to_date.strftime("%Y-%m-%d")
      else
        value.to_s
      end
    end

    def format_time_for_input(value)
      return if value.blank?

      str = value.to_s.strip
      return str if str.match?(/\A\d{1,2}:\d{2}(:\d{2})?\z/)

      value.strftime("%H:%M:%S") if value.respond_to?(:strftime)
    end

    def trigger_text
      date_part = if start_date.present? && end_date.present?
        "#{format_date_for_input(start_date)} – #{format_date_for_input(end_date)}"
      elsif start_date.present?
        "#{t('admin.shared.date_range_filter.from')} #{format_date_for_input(start_date)}"
      elsif end_date.present?
        "#{t('admin.shared.date_range_filter.to')} #{format_date_for_input(end_date)}"
      else
        t("admin.shared.date_range_filter.all_dates")
      end

      return date_part unless show_time && (start_time.present? || end_time.present?)

      time_part = [format_time_for_input(start_time), format_time_for_input(end_time)].compact.join(" – ")
      "#{date_part} #{time_part}"
    end

    def show_clear_button?
      return false unless request.present?

      return true if start_date.present? || end_date.present?
      return true if show_time && (start_time.present? || end_time.present?)
      return true if show_date_column && date_column.present? && date_column != "created_at"

      # Only show clear for timezone when it differs from browser (clearing would have no effect otherwise)
      return false unless show_time_zone && time_zone_param_present

      browser_time_zone = request.cookies["browser_time_zone"]
      time_zone != browser_time_zone
    end

    def clear_url
      return unless request.present?

      params_to_remove = [start_date_param, end_date_param]
      params_to_remove << start_time_param << end_time_param if show_time
      params_to_remove << time_zone_param if show_time_zone
      params_to_remove << date_column_param if show_date_column
      RequestHelper.new(request).url_with_query({}, params_to_remove)
    end

    def clear_button_aria_label
      t("shared.aria.clear_filter", filter: t("admin.shared.date_range_filter.aria_label"))
    end

    def dropdown_id
      "admin_date_range_filter_dropdown_#{start_date_param}"
    end
  end
end
