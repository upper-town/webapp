module Admin
  class AccountMultiSelectFilterComponent < ApplicationComponent
    attr_reader :inner

    STATIC_OPTIONS = [[I18n.t("admin.shared.anonymous"), Admin::ServerVotesQuery::ANONYMOUS_VALUE]].freeze

    def initialize(form:, selected_ids: [], selected_labels: [], **extra)
      super()

      @form = form
      @selected_ids = selected_ids
      @selected_labels = selected_labels || []
      @extra = extra
    end

    def before_render
      @inner = Admin::FetchableMultiSelectFilterComponent.new(
        form: @form,
        param_name: "account_ids",
        selected_ids: @selected_ids,
        selected_labels: @selected_labels,
        static_options: STATIC_OPTIONS,
        placeholder: I18n.t("admin.shared.filter_multiselect_account_remote_placeholder"),
        all_label: I18n.t("admin.shared.filter_multiselect_all_accounts"),
        # rubocop:disable Style/FormatStringToken
        count_label: I18n.t("admin.shared.filter_multiselect_accounts_count.other"),
        count_label_one: I18n.t("admin.shared.filter_multiselect_accounts_count.one"),
        # rubocop:enable Style/FormatStringToken
        no_results_label: I18n.t("admin.shared.filter_multiselect_no_accounts_match"),
        search_url: helpers.admin_account_select_options_path,
        search_url_params: { only_with_votes: "true" },
        min_chars: 2,
        min_chars_label: I18n.t("admin.shared.filter_multiselect_account_remote_min_chars", count: 2),
        loading_label: I18n.t("admin.shared.filter_multiselect_account_remote_loading"),
        **@extra
      )
    end
  end
end
