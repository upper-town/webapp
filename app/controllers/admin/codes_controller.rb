# frozen_string_literal: true

module Admin
  class CodesController < BaseController
    def index
      @search_term = params[:q]
      relation = Admin::CodesQuery.new.call
      @pagination = Pagination.new(
        Admin::Queries::CodesQuery.call(Code, relation, @search_term),
        request,
        per_page: 50
      )
      @codes = @pagination.results

      render(status: :ok)
    end

    def show
      @code = code_from_params
    end

    private

    def code_from_params
      Code.includes(:user).find(params[:id])
    end
  end
end
