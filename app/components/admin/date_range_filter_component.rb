module Admin
  class DateRangeFilterComponent < ApplicationComponent
    DEFAULT_SELECT_CLASS = "form-select admin-servers-filter-inline__select btn"

    attr_reader :form, :start_date, :end_date, :param_prefix, :request

    def initialize(form:, start_date: nil, end_date: nil, param_prefix: nil, request: nil)
      super()

      @form = form
      @start_date = start_date
      @end_date = end_date
      @param_prefix = param_prefix
      @request = request
    end

    def start_date_param
      param_prefix.present? ? "#{param_prefix}_start_date" : "start_date"
    end

    def end_date_param
      param_prefix.present? ? "#{param_prefix}_end_date" : "end_date"
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

    def trigger_text
      if start_date.present? && end_date.present?
        "#{format_date_for_input(start_date)} – #{format_date_for_input(end_date)}"
      elsif start_date.present?
        "#{t('admin.shared.date_range_filter.from')} #{format_date_for_input(start_date)}"
      elsif end_date.present?
        "#{t('admin.shared.date_range_filter.to')} #{format_date_for_input(end_date)}"
      else
        t("admin.shared.date_range_filter.all_dates")
      end
    end

    def show_clear_button?
      request.present? && (start_date.present? || end_date.present?)
    end

    def clear_url
      return unless request.present?

      RequestHelper.new(request).url_with_query({}, [start_date_param, end_date_param])
    end

    def clear_button_aria_label
      t("shared.aria.clear_filter", filter: t("admin.shared.date_range_filter.aria_label"))
    end

    def dropdown_id
      "admin_date_range_filter_dropdown_#{start_date_param}"
    end
  end
end
