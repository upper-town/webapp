module Admin
  class ServerStatsFilterComponent < ApplicationComponent
    attr_reader :form, :selected_value_period

    FILTER_PARAMS = %w[period].freeze

    def initialize(
      form:,
      selected_value_period: nil,
      request: nil
    )
      super()

      @form = form
      @selected_value_period = selected_value_period
      @request = request
      # clear_url ignored; FilterComponent builds it from request via RequestHelper
    end

    def has_active_filters?
      selected_value_period.present?
    end

    def period_options
      [[t("admin.server_stats.index.filter.all_periods"), nil]] + Periods::PERIOD_OPTIONS
    end

    def select_class
      "form-select form-select-sm admin-servers-filter-inline__select"
    end
  end
end
