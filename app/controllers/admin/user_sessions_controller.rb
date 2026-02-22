# frozen_string_literal: true

module Admin
  class UserSessionsController < BaseController
    def index
      @user = User.find(params[:id])
      @search_term = params[:q]
      relation = Admin::SessionsQuery.new(user_id: @user.id).call
      @pagination = Pagination.new(
        Admin::Queries::SessionsQuery.call(Session, relation, @search_term),
        request,
        per_page: 50
      )
      @sessions = @pagination.results
    end
  end
end
