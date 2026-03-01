module Admin
  class ServerVotesFilterComponent < ApplicationComponent
    attr_reader :form, :selected_game_ids, :selected_server_ids, :selected_account_ids,
                :selected_account_labels, :game_options, :server_options

    FILTER_PARAMS = %w[game_ids[] server_ids[] account_ids[]].freeze

    def initialize(
      form:,
      selected_game_ids: nil,
      selected_server_ids: nil,
      selected_account_ids: nil,
      selected_account_labels: nil,
      game_options: nil,
      server_options: nil,
      request: nil
    )
      super()

      @form = form
      @selected_game_ids = Array(selected_game_ids).map(&:to_s).compact_blank
      @selected_server_ids = Array(selected_server_ids).map(&:to_s).compact_blank
      @selected_account_ids = Array(selected_account_ids).map(&:to_s).compact_blank
      @selected_account_labels = selected_account_labels || []
      @game_options = game_options || GameSelectOptionsQuery.call(only_in_use: true)
      @server_options = server_options || ServerSelectOptionsQuery.call(only_with_votes: true)
      @request = request
    end

    def has_active_filters?
      selected_game_ids.present? || selected_server_ids.present? || selected_account_ids.present?
    end
  end
end
