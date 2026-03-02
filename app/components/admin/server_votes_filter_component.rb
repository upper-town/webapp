module Admin
  class ServerVotesFilterComponent < ApplicationComponent
    attr_reader :form, :selected_game_ids, :selected_server_ids, :selected_account_ids,
                :selected_account_labels, :start_date, :end_date, :game_options, :server_options, :request

    FILTER_PARAMS = %w[game_ids[] server_ids[] account_ids[] start_date end_date].freeze

    def initialize(
      form:,
      selected_game_ids: nil,
      selected_server_ids: nil,
      selected_account_ids: nil,
      selected_account_labels: nil,
      start_date: nil,
      end_date: nil,
      game_options: nil,
      server_options: nil,
      request: nil
    )
      super()

      @form = form
      @selected_game_ids = normalize_ids(selected_game_ids)
      @selected_server_ids = normalize_ids(selected_server_ids)
      @selected_account_ids = normalize_ids(selected_account_ids)
      @selected_account_labels = selected_account_labels || []
      @start_date = start_date
      @end_date = end_date
      @game_options = game_options || GameSelectOptionsQuery.call(only_in_use: true)
      @server_options = server_options || ServerSelectOptionsQuery.call(only_with_votes: true)
      @request = request
    end

    def has_active_filters?
      selected_game_ids.present? || selected_server_ids.present? || selected_account_ids.present? ||
        start_date.present? || end_date.present?
    end
  end
end
