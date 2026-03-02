module Admin
  class PeriodMultiSelectFilterComponent < ApplicationComponent
    attr_reader :inner

    def initialize(form:, selected_ids: [], options: nil, **)
      super()

      @inner = Admin::MultiSelectFilterComponent.new(
        form:,
        param_name: "periods",
        options: options || period_options,
        selected_ids:,
        placeholder: I18n.t("admin.shared.filter_multiselect_period_placeholder"),
        all_label: I18n.t("admin.shared.filter_multiselect_all_periods"),
        count_label: I18n.t("admin.shared.filter_multiselect_periods_count.other"),
        count_label_one: I18n.t("admin.shared.filter_multiselect_periods_count.one"),
        no_results_label: I18n.t("admin.shared.filter_multiselect_no_periods_match"),
        **
      )
    end

    private

    def period_options
      Periods::PERIOD_OPTIONS
    end
  end
end
