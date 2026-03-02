module Admin
  class UserSessionsController < BaseController
    def index
      @user = User.find(params[:id])
      @search_term = params[:q]
      @sort_key = params[:sort_key].presence
      @sort_dir = params[:sort_dir].presence
      relation = Admin::SessionsQuery.call(
        user_id: @user.id,
        search_term: @search_term,
        sort_key: @sort_key,
        sort_dir: @sort_dir
      )
      @pagination = Pagination.new(relation, request, per_page: 50)
      @sessions = @pagination.results
    end
  end
end
