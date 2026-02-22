# frozen_string_literal: true

module Admin
  class AdminTokensController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::AdminTokensQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::AdminTokensQuery.call(AdminToken, relation, @search_term),
        request,
        per_page: 50
      )
      @admin_tokens = @pagination.results

      render(status: :ok)
    end

    def show
      @admin_token = admin_token_from_params
    end

    private

    def admin_token_from_params
      AdminToken.includes(:admin_user).find(params[:id])
    end
  end
end
