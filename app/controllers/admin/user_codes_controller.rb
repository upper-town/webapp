module Admin
  class UserCodesController < BaseController
    def index
      @user = User.find(params[:id])
      @search_term = params[:q]
      relation = Admin::CodesQuery.new(user_id: @user.id).call
      @pagination = Pagination.new(
        Admin::Queries::CodesQuery.call(Code, relation, @search_term),
        request,
        per_page: 50
      )
      @codes = @pagination.results
    end
  end
end
