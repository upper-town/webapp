module Admin
  class CountryMultiSelectFilterComponent < ApplicationComponent
    attr_reader :inner

    def initialize(form:, selected_ids: [], options: nil, **)
      super()

      @inner = Admin::MultiSelectFilterComponent.new(
        form:,
        param_name: "country_codes",
        options: options || country_options,
        selected_ids:,
        placeholder: I18n.t("admin.shared.filter_multiselect_country_placeholder"),
        all_label: I18n.t("admin.shared.filter_multiselect_all_countries"),
        count_label: I18n.t("admin.shared.filter_multiselect_countries_count.other"),
        count_label_one: I18n.t("admin.shared.filter_multiselect_countries_count.one"),
        no_results_label: I18n.t("admin.shared.filter_multiselect_no_countries_match"),
        **
      )
    end

    private

    def country_options
      CountrySelectOptionsQuery.call(only_in_use: true)
    end
  end
end
