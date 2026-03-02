module Servers
  class IndexFilterComponent < ApplicationComponent
    attr_reader(
      :form,
      :selected_value_game_ids,
      :selected_value_period,
      :selected_value_country_codes
    )

    def initialize(
      form:,
      selected_value_game_ids: nil,
      selected_value_period: Periods::MONTH,
      selected_value_country_codes: nil
    )
      super()

      @form = form
      @selected_value_game_ids = normalize_ids(selected_value_game_ids)
      @selected_value_period = selected_value_period
      @selected_value_country_codes = normalize_ids(selected_value_country_codes)
    end

    def has_active_filters?
      selected_value_game_ids.present? ||
        selected_value_period != Periods::MONTH ||
        selected_value_country_codes.present?
    end

    def clear_url
      servers_path
    end
  end
end
