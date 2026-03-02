module Admin
  class StatusMultiSelectFilterComponent < ApplicationComponent
    STATUS_IDS = %w[verified not_verified archived not_archived marked_for_deletion].freeze

    attr_reader :inner

    def initialize(form:, selected_ids: [], options: nil, **)
      super()

      @inner = Admin::MultiSelectFilterComponent.new(
        form:,
        param_name: "status",
        options: options || status_options,
        selected_ids:,
        placeholder: I18n.t("admin.shared.filter_multiselect_status_placeholder"),
        all_label: I18n.t("admin.shared.filter_multiselect_all_statuses"),
        count_label: I18n.t("admin.shared.filter_multiselect_statuses_count.other"),
        count_label_one: I18n.t("admin.shared.filter_multiselect_statuses_count.one"),
        no_results_label: I18n.t("admin.shared.filter_multiselect_no_statuses_match"),
        **
      )
    end

    private

    def status_options
      STATUS_IDS.map { |id| [I18n.t("admin.servers.index.filter.#{id}"), id] }
    end
  end
end
