module Admin
  class ServerMultiSelectFilterComponent < ApplicationComponent
    attr_reader :inner

    def initialize(form:, selected_ids: [], options: nil, **)
      super()

      @inner = Admin::MultiSelectFilterComponent.new(
        form:,
        param_name: "server_ids",
        options: options || ServerSelectOptionsQuery.call(only_with_votes: true),
        selected_ids:,
        placeholder: I18n.t("admin.shared.filter_multiselect_server_placeholder"),
        all_label: I18n.t("admin.shared.filter_multiselect_all_servers"),
        # rubocop:disable Style/FormatStringToken
        count_label: I18n.t("admin.shared.filter_multiselect_servers_count.other"),
        count_label_one: I18n.t("admin.shared.filter_multiselect_servers_count.one"),
        # rubocop:enable Style/FormatStringToken
        no_results_label: I18n.t("admin.shared.filter_multiselect_no_servers_match"),
        **
      )
    end
  end
end
