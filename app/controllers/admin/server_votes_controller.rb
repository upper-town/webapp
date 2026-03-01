module Admin
  class ServerVotesController < BaseController
    def index
      @search_term = params[:q]
      @sort_column = params[:sort].presence
      @sort_direction = params[:sort_dir].presence
      relation = Admin::ServerVotesQuery.call(
        server_id: params[:server_id],
        game_id: params[:game_id],
        account_id: params[:account_id],
        sort: @sort_column,
        sort_dir: @sort_direction
      )
      @pagination = Pagination.new(
        Admin::Queries::ServerVotesQuery.call(ServerVote, relation, @search_term),
        request,
        per_page: 50
      )
      @server_votes = @pagination.results
      @server = Server.find_by(id: params[:server_id]) if params[:server_id].present?
      @game = Game.find_by(id: params[:game_id]) if params[:game_id].present?
      @account = Account.find_by(id: params[:account_id]) if params[:account_id].present?

      render(status: :ok)
    end

    def show
      @server_vote = server_vote_from_params
    end

    private

    def server_vote_from_params
      ServerVote.includes(:server, :game, account: :user).find(params[:id])
    end
  end
end
