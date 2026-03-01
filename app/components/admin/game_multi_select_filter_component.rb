module Admin
  class GameMultiSelectFilterComponent < ApplicationComponent
    attr_reader :inner

    def initialize(form:, selected_ids: [], options: nil, **)
      super()

      @inner = Admin::MultiSelectFilterComponent.new(
        form:,
        param_name: "game_ids",
        options: options || GameSelectOptionsQuery.call(only_in_use: true),
        selected_ids:,
        placeholder: I18n.t("admin.shared.filter_multiselect_game_placeholder"),
        all_label: I18n.t("admin.shared.filter_multiselect_all_games"),
        # rubocop:disable Style/FormatStringToken
        count_label: I18n.t("admin.shared.filter_multiselect_games_count.other"),
        count_label_one: I18n.t("admin.shared.filter_multiselect_games_count.one"),
        # rubocop:enable Style/FormatStringToken
        no_results_label: I18n.t("admin.shared.filter_multiselect_no_games_match"),
        **
      )
    end
  end
end
