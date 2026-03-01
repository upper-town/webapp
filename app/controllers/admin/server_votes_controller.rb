module Admin
  class ServerVotesController < BaseController
    def index
      @search_term = params[:q]
      @filter_game_ids = params[:game_ids]
      @filter_server_ids = params[:server_ids]
      @filter_account_ids = params[:account_ids]
      @sort_column = params[:sort].presence
      @sort_direction = params[:sort_dir].presence
      relation = Admin::ServerVotesQuery.call(
        server_id: params[:server_id],
        game_id: params[:game_id],
        account_id: params[:account_id],
        game_ids: @filter_game_ids,
        server_ids: @filter_server_ids,
        account_ids: @filter_account_ids,
        sort: @sort_column,
        sort_dir: @sort_direction
      )
      @pagination = Pagination.new(
        Admin::Queries::ServerVotesQuery.call(ServerVote, relation, @search_term),
        request,
        per_page: 50
      )
      @server_votes = @pagination.results
      @server = single_record_for_subtitle(Server, params[:server_id], params[:server_ids])
      @game = single_record_for_subtitle(Game, params[:game_id], params[:game_ids])
      @filter_account_labels = build_filter_account_labels(@filter_account_ids)

      render(status: :ok)
    end

    def show
      @server_vote = server_vote_from_params
    end

    private

    def single_record_for_subtitle(model, single_id_param, ids_param)
      ids = Array(ids_param).compact_blank
      id = single_id_param.presence || (ids.one? ? ids.first : nil)
      model.find_by(id:) if id.present?
    end

    def build_filter_account_labels(account_ids)
      ids = Array(account_ids).map(&:to_s).compact_blank
      return [] if ids.empty?

      anonymous_label = I18n.t("admin.shared.anonymous")
      numeric_ids = ids.reject { |id| id == Admin::ServerVotesQuery::ANONYMOUS_VALUE }
      return ids.map { |id| [anonymous_label, id] } if numeric_ids.empty?

      lookup = AccountSelectOptionsQuery.call(
        ids: numeric_ids,
        only_with_votes: true,
        cache_enabled: false
      ).to_h { |name, opt_id| [opt_id.to_s, [name, opt_id]] }

      ids.map do |id|
        if id == Admin::ServerVotesQuery::ANONYMOUS_VALUE
          [anonymous_label, id]
        else
          lookup[id]
        end
      end.compact
    end

    def server_vote_from_params
      ServerVote.includes(:server, :game, account: :user).find(params[:id])
    end
  end
end
