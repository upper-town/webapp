# frozen_string_literal: true

module Admin
  class UserTokensController < BaseController
    def index
      @user = User.find(params[:id])
      @search_term = params[:q]
      relation = Admin::TokensQuery.new(user_id: @user.id).call
      @pagination = Pagination.new(
        Admin::Queries::TokensQuery.call(Token, relation, @search_term),
        request,
        per_page: 50
      )
      @tokens = @pagination.results
    end
  end
end
