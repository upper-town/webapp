module Admin
  class ServersFilterComponent < ApplicationComponent
    DEFAULT_SELECT_CLASS = "form-select form-select-sm admin-servers-filter-inline__select"

    attr_reader :form, :selected_status_ids, :selected_country_codes, :selected_game_ids, :game_options, :request, :hide_game_filter

    FILTER_PARAMS = %w[status[] country_codes[] game_ids[]].freeze

    def initialize(
      form:,
      selected_status_ids: nil,
      selected_country_codes: nil,
      selected_game_ids: nil,
      game_options: nil,
      request: nil,
      hide_game_filter: false
    )
      super()

      @form = form
      @selected_status_ids = normalize_ids(selected_status_ids)
      @selected_country_codes = normalize_ids(selected_country_codes)
      @selected_game_ids = normalize_ids(selected_game_ids)
      @game_options = game_options || GameSelectOptionsQuery.call(only_in_use: true)
      @request = request
      @hide_game_filter = hide_game_filter
    end

    def has_active_filters?
      selected_status_ids.present? || selected_country_codes.present? || (!hide_game_filter && selected_game_ids.present?)
    end

    def select_class
      DEFAULT_SELECT_CLASS
    end
  end
end
