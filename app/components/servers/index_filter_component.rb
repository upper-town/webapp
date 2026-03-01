module Servers
  class IndexFilterComponent < ApplicationComponent
    attr_reader(
      :form,
      :selected_value_game_id,
      :selected_value_period,
      :selected_value_country_code
    )

    def initialize(
      form:,
      selected_value_game_id: nil,
      selected_value_period: Periods::MONTH,
      selected_value_country_code: nil
    )
      super()

      @form = form
      @selected_value_game_id = selected_value_game_id
      @selected_value_period = selected_value_period
      @selected_value_country_code = selected_value_country_code
    end

    def has_active_filters?
      selected_value_game_id.present? ||
        selected_value_period != Periods::MONTH ||
        selected_value_country_code.present?
    end

    def clear_url
      servers_path
    end
  end
end
