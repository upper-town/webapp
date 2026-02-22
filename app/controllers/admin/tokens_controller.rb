# frozen_string_literal: true

module Admin
  class TokensController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::TokensQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::TokensQuery.call(Token, relation, @search_term),
        request,
        per_page: 50
      )
      @tokens = @pagination.results

      render(status: :ok)
    end

    def show
      @token = token_from_params
    end

    private

    def token_from_params
      Token.includes(:user).find(params[:id])
    end
  end
end
