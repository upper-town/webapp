module Admin
  class AccountSelectOptionsController < BaseController
    ANONYMOUS_OPTION = [[I18n.t("admin.shared.anonymous"), Admin::ServerVotesQuery::ANONYMOUS_VALUE]].freeze

    def index
      ids_param = params[:ids].to_s.split(",").map(&:strip).compact_blank
      search_term = params[:q].presence&.squish
      limit = params[:limit].presence&.to_i || AccountSelectOptionsQuery::DEFAULT_LIMIT
      only_with_votes = params[:only_with_votes] == "true"
      selected_ids = Array(params[:selected_ids]).map(&:to_s).compact_blank

      options = build_options(
        ids_param:,
        search_term:,
        limit:,
        only_with_votes:,
        selected_ids:
      )

      @options = options
      @selected_ids = selected_ids
      @turbo_frame_id = request.headers["Turbo-Frame"].presence || "admin_fetchable_multi_select_filter_options_account_ids"

      respond_to do |format|
        format.html do
          if request.headers["Turbo-Frame"].present?
            render(
              partial: "admin/account_select_options/frame",
              locals: {
                turbo_frame_id: @turbo_frame_id,
                options: @options,
                selected_ids: @selected_ids
              },
              layout: false
            )
          else
            render(layout: false)
          end
        end
      end
    end

    private

    def build_options(ids_param:, search_term:, limit:, only_with_votes:, selected_ids:)
      # ids_param: options lookup for specific ids (backward compat, e.g. direct URL)
      # search_term: filter options by email
      # selected_ids: always include these in options so user can deselect

      if ids_param.present? && search_term.blank?
        options = AccountSelectOptionsQuery.call(
          ids: ids_param,
          only_with_votes:,
          cache_enabled: false
        )
        return ANONYMOUS_OPTION + options
      end

      selected_account_ids = selected_ids.reject { |id| id == Admin::ServerVotesQuery::ANONYMOUS_VALUE }

      if search_term.blank?
        # No search: return only Anonymous + selected options (for dropdown reopen after form submit)
        return ANONYMOUS_OPTION if selected_account_ids.empty?

        selected_options = AccountSelectOptionsQuery.call(
          ids: selected_account_ids,
          only_with_votes:,
          cache_enabled: false
        )
        selected_lookup = selected_options.to_h { |name, id| [id.to_s, [name, id]] }
        ordered_selected = selected_account_ids.filter_map { |id| selected_lookup[id] }
        return ANONYMOUS_OPTION + ordered_selected
      end

      # Search: get results, ensure selected are included
      search_options = AccountSelectOptionsQuery.call(
        search_term:,
        limit:,
        only_with_votes:,
        cache_enabled: false
      )

      search_ids = search_options.to_set { |_, id| id.to_s }
      missing_selected = selected_account_ids.reject { |id| search_ids.include?(id) }

      selected_options = if missing_selected.any?
        AccountSelectOptionsQuery.call(
          ids: missing_selected,
          only_with_votes:,
          cache_enabled: false
        )
      else
        []
      end

      # Order: Anonymous, selected (in selected_ids order), then search results (excluding duplicates)
      # When all selected are in search results, selected_options is empty; use search_options for lookup
      selected_lookup = selected_options.to_h { |name, id| [id.to_s, [name, id]] }
      search_options.each { |name, id| selected_lookup[id.to_s] ||= [name, id] }
      ordered_selected = selected_account_ids.filter_map { |id| selected_lookup[id] }
      search_without_selected = search_options.reject { |_, id| selected_account_ids.include?(id.to_s) }

      ANONYMOUS_OPTION + ordered_selected + search_without_selected
    end
  end
end
