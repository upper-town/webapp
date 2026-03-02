module Admin
  class ServerStatsFilterComponent < ApplicationComponent
    attr_reader :form, :selected_period_ids, :request

    FILTER_PARAMS = %w[periods[]].freeze

    def initialize(
      form:,
      selected_period_ids: nil,
      request: nil
    )
      super()

      @form = form
      @selected_period_ids = normalize_ids(selected_period_ids)
      @request = request
    end

    def has_active_filters?
      selected_period_ids.present?
    end
  end
end
